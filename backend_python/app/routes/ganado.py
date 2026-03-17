from fastapi import APIRouter, HTTPException
from typing import List
from datetime import datetime
from app.models.animal import Animal
from app.database import database  

router = APIRouter()

@router.post("/")
async def crear_vaca(animal: Animal):
    animal_dict = animal.model_dump()
    try:
        nuevo_ganado = await database["ganado"].insert_one(animal_dict)
        return {"mensaje": "Vaca registrada", "id": str(nuevo_ganado.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/")
async def listar_ganado():
    ganado = await database["ganado"].find().to_list(100)
    for v in ganado:
        v["_id"] = str(v["_id"])
    return ganado

@router.post("/sync")
async def sincronizar_lote(lote: List[Animal]):
    registros_nuevos = 0
    registros_actualizados = 0
    
    for animal in lote:
        animal_dict = animal.model_dump()
        # Buscamos por el campo único de tu esquema
        existente = await database["ganado"].find_one({"codigoQR": animal.codigoQR})
        
        if existente:
            # Resolución de conflictos: Comparar fechas
            if animal.ultima_modificacion > existente.get("ultima_modificacion", datetime.min):
                await database["ganado"].update_one(
                    {"codigoQR": animal.codigoQR},
                    {"$set": animal_dict}
                )
                registros_actualizados += 1
        else:
            await database["ganado"].insert_one(animal_dict)
            registros_nuevos += 1
            
    return {
        "estado": "Sincronización completada",
        "nuevos": registros_nuevos,
        "actualizados": registros_actualizados
    }