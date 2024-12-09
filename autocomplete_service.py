from fastapi import APIRouter, FastAPI
from pydantic import BaseModel

router = APIRouter()


class AutocompleteRequest(BaseModel):
    prefix: str
    max_suggestions: int = 5


@router.post("/autocomplete")
async def get_completions(request: AutocompleteRequest):
    # כאן תוכל להגדיר את ההצעות שאתה רוצה שיופיעו
    common_phrases = [
        "מה המשמעות של",
        "איך אני יכול",
        "תסביר לי על",
        "מה ההבדל בין",
        # הוסף עוד הצעות
    ]

    suggestions = [
                      phrase for phrase in common_phrases
                      if phrase.startswith(request.prefix)
                  ][:request.max_suggestions]

    return {"suggestions": suggestions}