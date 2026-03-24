from fastapi import APIRouter, HTTPException
from typing import List
from datetime import datetime

from app.models.animal import Animal, Vacuna, RevisionMedica
from app.database import database


router = APIRouter()


# ---------------------------------
# Crear animal
# ---------------------------------
@router.post("/")
async def crear_vaca(animal: Animal):

    animal_dict = animal.model_dump()

    try:
        nuevo_ganado = await database["ganado"].insert_one(animal_dict)

        return {
            "mensaje": "Vaca registrada",
            "id": str(nuevo_ganado.inserted_id)
        }

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


# ---------------------------------
# Listar ganado
# ---------------------------------
@router.get("/")
async def listar_ganado():

    ganado = await database["ganado"].find().to_list(100)

    for v in ganado:
        v["_id"] = str(v["_id"])

    return ganado


# ---------------------------------
# Historia 5 — Sincronización por lote
# ---------------------------------
@router.post("/sync")
async def sincronizar_lote(lote: List[Animal]):

    registros_nuevos = 0
    registros_actualizados = 0

    for animal in lote:

        animal_dict = animal.model_dump()

        existente = await database["ganado"].find_one(
            {"codigoQR": animal.codigoQR}
        )

        if existente:

            if animal.ultima_modificacion > existente.get(
                "ultima_modificacion",
                datetime.min
            ):

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


# ---------------------------------
# Historia 3 — Registrar vacuna
# ---------------------------------
@router.post("/{codigoQR}/vacuna")
async def agregar_vacuna(   
    codigoQR: str,
    nueva_vacuna: Vacuna
):

    resultado = await database["ganado"].update_one(

        {"codigoQR": codigoQR},

        {
            "$push": {
                "historial_vacunas":
                    nueva_vacuna.model_dump()
            },

            "$set": {
                "ultima_modificacion": datetime.now()
            }
        }
    )

    if resultado.modified_count == 0:
        raise HTTPException(
            status_code=404,
            detail="Animal no encontrado"
        )

    return {
        "mensaje": "Vacuna registrada exitosamente"
    }


# ---------------------------------
# Historia 4 — Registrar revisión médica
# ---------------------------------
@router.post("/{codigoQR}/revision")
async def agregar_revision(
    codigoQR: str,
    revision: RevisionMedica
):

    resultado = await database["ganado"].update_one(

        {"codigoQR": codigoQR},

        {
            "$push": {
                "historial_clinico":
                    revision.model_dump()
            },

            "$set": {
                "ultima_modificacion": datetime.now()
            }
        }
    )

    if resultado.modified_count == 0:
        raise HTTPException(
            status_code=404,
            detail="Animal no encontrado"
        )

    return {
        "mensaje": "Revisión médica documentada"
    }


# ---------------------------------
# Obtener historial completo
# ---------------------------------
@router.get("/{codigoQR}/historial")
async def obtener_historial_completo(
    codigoQR: str
):

    animal = await database["ganado"].find_one(
        {"codigoQR": codigoQR}
    )

    if not animal:
        raise HTTPException(
            status_code=404,
            detail="Animal no encontrado"
        )

    animal["historial_vacunas"].sort(
        key=lambda x: x["fecha_aplicacion"],
        reverse=True
    )

    animal["historial_clinico"].sort(
        key=lambda x: x["fecha_revision"],
        reverse=True
    )

    animal["_id"] = str(animal["_id"])

    return {
        "codigoQR": animal["codigoQR"],
        "vacunas": animal["historial_vacunas"],
        "clinico": animal["historial_clinico"]
    }