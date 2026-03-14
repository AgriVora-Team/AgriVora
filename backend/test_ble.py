import asyncio
from bleak import BleakScanner, BleakClient

MAC_ADDRESS = "70:4B:CA:8D:A7:86"
UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8"

async def scan_devices():
    devices = await BleakScanner.discover(timeout=5.0)
    for d in devices:
        print(f"{d.address} | {d.name}")
    return devices


async def connect_device(address):
    device = await BleakScanner.find_device_by_address(address, timeout=10.0)

    if not device:
        print(f"Device {address} not found")
        return None

    print(f"Found device: {device.name} ({device.address})")
    return device


async def read_services(client):
    services = await client.get_services()

    for service in services:
        print(service)

        for char in service.characteristics:
            print(f"  - {char.uuid} | {char.properties}")

            if "read" in char.properties:
                try:
                    val = await client.read_gatt_char(char.uuid)
                    print(f"    Value: {val}")
                except Exception as e:
                    print(f"    Read failed: {e}")


async def main():
    print("Scanning for BLE devices...")
    await scan_devices()

    device = await connect_device(MAC_ADDRESS)
    if not device:
        return

    try:
        async with BleakClient(device) as client:
            print(f"Connected: {client.is_connected}")

            await read_services(client)

            try:
                data = await client.read_gatt_char(UUID)
                print(f"Target UUID {UUID} value: {data}")
            except Exception as e:
                print(f"Failed to read target UUID: {e}")

    except Exception as e:
        print(f"BLE connection error: {e}")


if __name__ == "__main__":
    asyncio.run(main())