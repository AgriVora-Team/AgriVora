import os
from fastapi import APIRouter
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
from g4f.client import Client as FreeClient

load_dotenv(override=True)

router = APIRouter()


class ChatRequest(BaseModel):
    message: str


class AIChatService:
    def __init__(self):
        self.system_prompt = (
            "You are AgriVora AI, a highly specialized agricultural expert. "
            "You help farmers optimize their crop yields, analyze soil health, "
            "and provide sustainable farming practices. Be professional, "
            "encouraging, and provide specific, actionable advice."
        )
        self.api_key = os.getenv("OPENAI_API_KEY")

    def build_success(self, reply: str):
        return {
            "success": True,
            "data": {"reply": reply},
            "error": None
        }

    def build_error(self, error: str):
        return {
            "success": False,
            "data": None,
            "error": error
        }

    def use_openai(self, message: str):
        client = OpenAI(api_key=self.api_key)

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": message}
            ],
            max_tokens=500,
            temperature=0.7
        )

        return response.choices[0].message.content

    def use_free_fallback(self, message: str):
        client = FreeClient()

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": message}
            ]
        )

        return response.choices[0].message.content

    def can_try_openai(self):
        return self.api_key is not None and self.api_key.strip() != ""

    def fallback_allowed(self, error_message: str):
        return (
            "insufficient_quota" in error_message
            or "invalid_api_key" in error_message
            or "Incorrect API key" in error_message
        )


@router.post("/chat")
async def chat_with_ai(data: ChatRequest):
    service = AIChatService()

    if service.can_try_openai():
        try:
            reply = service.use_openai(data.message)
            return service.build_success(reply)
        except Exception as e:
            error_text = str(e)
            if not service.fallback_allowed(error_text):
                return service.build_error(error_text)

    try:
        reply = service.use_free_fallback(data.message)
        return service.build_success(reply)
    except Exception as e:
        return service.build_error(f"AgriVora Free Agent error: {str(e)}")