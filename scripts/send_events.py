#!/usr/bin/env python3
"""
IoT Event Generator Script

Simuleert IoT sensoren die events sturen naar Azure Event Hub.
Gebruikt voor het testen van de IoT Data Pipeline.

Installatie:
    pip install azure-eventhub

Gebruik:
    python send_events.py --connection-string "<EVENT_HUB_CONNECTION_STRING>" --count 100

Of via environment variable:
    export EVENT_HUB_CONNECTION_STRING="<connection_string>"
    python send_events.py
"""

import asyncio
import argparse
import json
import os
import random
from datetime import datetime, timezone
from typing import Optional

try:
    from azure.eventhub import EventData
    from azure.eventhub.aio import EventHubProducerClient
except ImportError:
    print("❌ azure-eventhub niet geïnstalleerd!")
    print("   Installeer met: pip install azure-eventhub")
    exit(1)


def generate_iot_event(device_id: Optional[str] = None) -> dict:
    """Genereert een realistisch IoT sensor event."""
    if device_id is None:
        device_id = f"sensor-{random.randint(1, 10):03d}"

    return {
        "device_id": device_id,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "location": random.choice(["Amsterdam", "Rotterdam", "Utrecht", "Eindhoven"]),
        "measurements": {
            "temperature": round(random.uniform(15.0, 30.0), 2),
            "humidity": round(random.uniform(30.0, 80.0), 2),
            "pressure": round(random.uniform(1000.0, 1030.0), 2),
            "co2_ppm": random.randint(400, 1200),
        },
        "battery_level": round(random.uniform(20.0, 100.0), 1),
        "signal_strength": random.randint(-90, -30),
    }


async def send_events(
    connection_string: str,
    eventhub_name: str,
    event_count: int,
    batch_size: int = 50,
    delay_seconds: float = 0.1,
) -> None:
    """Stuurt IoT events naar Event Hub."""
    producer = EventHubProducerClient.from_connection_string(
        conn_str=connection_string,
        eventhub_name=eventhub_name,
    )

    total_sent = 0
    print(f"🚀 Start met versturen van {event_count} events naar '{eventhub_name}'...")
    print(f"   Batch grootte: {batch_size}")
    print()

    async with producer:
        while total_sent < event_count:
            batch = await producer.create_batch()
            events_in_batch = 0

            while events_in_batch < batch_size and total_sent + events_in_batch < event_count:
                event = generate_iot_event()
                event_data = EventData(json.dumps(event))

                try:
                    batch.add(event_data)
                    events_in_batch += 1
                except ValueError:
                    break

            await producer.send_batch(batch)
            total_sent += events_in_batch

            progress = (total_sent / event_count) * 100
            print(f"   ✅ Verstuurd: {total_sent}/{event_count} ({progress:.1f}%)")

            if total_sent < event_count:
                await asyncio.sleep(delay_seconds)

    print()
    print(f"🎉 Klaar! {total_sent} events succesvol verstuurd.")


def main():
    parser = argparse.ArgumentParser(
        description="IoT Event Generator - Stuurt test events naar Azure Event Hub"
    )
    parser.add_argument(
        "--connection-string", "-c",
        help="Event Hub connection string",
        default=os.environ.get("EVENT_HUB_CONNECTION_STRING"),
    )
    parser.add_argument(
        "--eventhub-name", "-n",
        help="Naam van de Event Hub",
        default=os.environ.get("EVENT_HUB_NAME", "iot-events"),
    )
    parser.add_argument(
        "--count", "-e",
        type=int,
        default=100,
        help="Aantal events (default: 100)",
    )

    args = parser.parse_args()

    if not args.connection_string:
        print("❌ Geen connection string opgegeven!")
        print()
        print("Gebruik:")
        print("  python send_events.py --connection-string '<connection_string>'")
        print()
        print("Of haal de connection string op na deployment:")
        print("  az deployment group show --resource-group rg-iot-workshop \\")
        print("    --name main --query 'properties.outputs.eventHubConnectionString.value' -o tsv")
        exit(1)

    asyncio.run(
        send_events(
            connection_string=args.connection_string,
            eventhub_name=args.eventhub_name,
            event_count=args.count,
        )
    )


if __name__ == "__main__":
    main()
