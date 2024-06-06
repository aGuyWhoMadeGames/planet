import asyncio
import websockets
from enum import IntEnum
import json
import random

class Message(IntEnum):
    SET_ID          = 0
    SET_SERVER      = 1
    GET_SERVERS     = 2
    SERVER_LIST     = 3
    START_RTC       = 4
    SET_DESCRIPTION = 5
    SET_ICE         = 6
    SET_GAME        = 7

ids = {}
servers = []

async def signal(websocket):
    sid = random.randrange((1<<31)-1)
    ids[sid] = websocket

    try:
        await websocket.send(json.dumps({
            "type":Message.SET_ID,
            "id":sid
            }))
        print(f'Client connected: {sid}')
        async for message in websocket:
            data = json.loads(message)
            match int(data["type"]):
                case Message.SET_SERVER:
                    servers.append(sid)
                    print(f"Server: {sid}")
                case Message.GET_SERVERS:
                    await websocket.send(json.dumps({
                        "type":Message.SERVER_LIST,
                        "servers":servers
                        }))
                case Message.START_RTC | Message.SET_DESCRIPTION | Message.SET_ICE:
                    to_id = int(data['id'])
                    data['id'] = sid
                    await ids[to_id].send(json.dumps(data))
    except OSError:
        pass
    finally:
        print(f"Client disconnected: {sid}")
        del ids[sid]
        if sid in servers:
            servers.remove(sid)

async def main():
    async with websockets.serve(signal, None, 9089):
        print("Server started")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
