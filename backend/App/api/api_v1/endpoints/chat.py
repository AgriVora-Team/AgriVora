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


def success_response(reply: str):
    return {
        "success": True,
        "data": {"reply": reply},
        "error": None
    }


def error_response(message: str):
    return {
        "success": False,
        "data": None,
        "error": message
    }


def get_system_prompt():
    return (
        "You are AgriVora AI, a highly specialized agricultural expert. "
        "You help farmers optimize their crop yields, analyze soil health, "
        "and provide sustainable farming practices. Be professional, "
        "encouraging, and provide specific, actionable advice."
    )


def ask_openai(api_key: str, user_message: str, system_prompt: str) -> str:
    client = OpenAI(api_key=api_key)

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message}
        ],
        max_tokens=500,
        temperature=0.7
    )

    return response.choices[0].message.content


def ask_free_client(user_message: str, system_prompt: str) -> str:
    client = FreeClient()

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message}
        ]
    )

    return response.choices[0].message.content


def should_fallback(error_text: str) -> bool:
    fallback_errors = [
        "insufficient_quota",
        "invalid_api_key",
        "Incorrect API key"
    ]
    return any(item in error_text for item in fallback_errors)


@router.post("/chat")
async def chat_with_ai(data: ChatRequest):
    api_key = os.getenv("OPENAI_API_KEY")
    system_prompt = get_system_prompt()

    if api_key and api_key.strip():
        try:
            reply = ask_openai(api_key, data.message, system_prompt)
            return success_response(reply)
        except Exception as e:
            error_msg = str(e)
            if not should_fallback(error_msg):
                return error_response(error_msg)

    try:
        reply = ask_free_client(data.message, system_prompt)
        return success_response(reply)
    except Exception as e:
        return error_response(f"AgriVora Free Agent error: {str(e)}")