from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from typing import List, Dict, Any, Optional

# Import the existing logic
from ingredients_analysis import analyze_ingredients_strict
from chat_bot import chat_bot

# Import database functions
from database.auth_sign_up import sign_up_user
from database.auth_sign_in import auth_login
from database.auth_get_user import get_user_by_id
from database.auth_update_profile import update_user_profile
from database.auth_update_password import update_user_password
from database.auth_delete_user import delete_user_account
from database.auth_email_exists import email_exists
from database.auth_resend_verification import resend_verification_email
from database.skin_profile_update import update_skin_profile
from database.skin_profile_skip import increment_wizard_skip
from database.report_make import make_report
from database.report_fetch import fetch_reports
from database.report_edit import edit_report
from database.report_delete import delete_report
from database.product_search import search_products
from database.product_fetch import fetch_products_by_status

app = FastAPI(title="Cosmetics Ingredients Analysis & API Backend")

# Add CORS middleware to allow requests from any origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ----------------- Existing API Schemas & Endpoints -----------------

class AnalyzeRequest(BaseModel):
    ingredients_str: str

@app.post("/analyze")
async def analyze_ingredients(request: AnalyzeRequest):
    """
    Endpoint to analyze a comma-separated list of ingredients.
    """
    result = analyze_ingredients_strict(request.ingredients_str)
    return result

class ChatInitRequest(BaseModel):
    product_name: str
    ingredients: str
    skin_profile: str

@app.post("/chat/init/product")
async def chat_init_product(request: ChatInitRequest):
    """
    Initialize a chat session from a product page.
    """
    context = {
        "product_name": request.product_name,
        "ingredients": request.ingredients,
        "skin_profile": request.skin_profile
    }
    reply = chat_bot.generate_initial_analysis(context)
    return {"reply": reply}

class ChatMessageRequest(BaseModel):
    flow_type: str
    history: List[Dict[str, str]]
    new_message: str
    context: Dict[str, Any]

@app.post("/chat/message")
async def chat_message(request: ChatMessageRequest):
    """
    Process an ongoing chat message.
    """
    result = chat_bot.process_message(
        flow_type=request.flow_type,
        history=request.history,
        new_message=request.new_message,
        context=request.context
    )
    return result

# ----------------- Database Schemas & Endpoints -----------------

class EmailExistsRequest(BaseModel):
    email: str

@app.post("/api/auth/email_exists")
async def api_email_exists(request: EmailExistsRequest):
    try:
        exists = email_exists(request.email)
        return {"status": "success", "exists": exists}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class SignUpRequest(BaseModel):
    username: str
    email: str
    password: str


@app.post("/api/auth/signup")
async def api_signup(request: SignUpRequest):
    try:
        user_id = sign_up_user(request.username, request.email, request.password)
        return {"status": "success", "user_id": user_id}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class LoginRequest(BaseModel):
    email: str
    password: str

@app.post("/api/auth/login")
async def api_login(request: LoginRequest):
    try:
        user_data = auth_login(request.email, request.password)
        return {"status": "success", "user": user_data}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class ResendVerificationRequest(BaseModel):
    email: str

@app.post("/api/auth/resend_verification")
async def api_resend_verification(request: ResendVerificationRequest):
    try:
        resend_verification_email(request.email)
        return {"status": "success"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class GetUserRequest(BaseModel):
    user_id: str

@app.post("/api/auth/user")
async def api_get_user(request: GetUserRequest):
    try:
        user_data = get_user_by_id(request.user_id)
        return {"status": "success", "user": user_data}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class UpdateProfileRequest(BaseModel):
    user_id: str
    username: Optional[str] = None
    email: Optional[str] = None

@app.post("/api/auth/update_profile")
async def api_update_profile(request: UpdateProfileRequest):
    try:
        result = update_user_profile(request.user_id, request.username, request.email)
        return result
    except Exception as e:
        return {"status": "error", "message": str(e)}

class UpdatePasswordRequest(BaseModel):
    user_id: str
    new_password: str

@app.post("/api/auth/update_password")
async def api_update_password(request: UpdatePasswordRequest):
    try:
        result = update_user_password(request.user_id, request.new_password)
        return result
    except Exception as e:
        return {"status": "error", "message": str(e)}

class DeleteUserRequest(BaseModel):
    user_id: str

@app.post("/api/auth/delete_user")
async def api_delete_user(request: DeleteUserRequest):
    try:
        result = delete_user_account(request.user_id)
        return result
    except Exception as e:
        return {"status": "error", "message": str(e)}

class UpdateSkinProfileRequest(BaseModel):
    user_id: str
    skin_types: List[str]
    skin_concerns: List[str]
    allergies: List[str]

@app.post("/api/skin_profile/update")
async def api_update_skin_profile(request: UpdateSkinProfileRequest):
    try:
        result = update_skin_profile(request.user_id, request.skin_types, request.skin_concerns, request.allergies)
        return result
    except Exception as e:
        return {"status": "error", "message": str(e)}

class IncrementWizardSkipRequest(BaseModel):
    user_id: str

@app.post("/api/skin_profile/skip")
async def api_increment_wizard_skip(request: IncrementWizardSkipRequest):
    try:
        result = increment_wizard_skip(request.user_id)
        return result
    except Exception as e:
        return {"status": "error", "message": str(e)}

class MakeReportRequest(BaseModel):
    report_data: Dict[str, Any]

@app.post("/api/reports/make")
async def api_make_report(request: MakeReportRequest):
    try:
        result = make_report(request.report_data)
        return result
    except Exception as e:
        return {"status": "error", "message": str(e)}

class FetchReportsRequest(BaseModel):
    user_id: str

@app.post("/api/reports/fetch")
async def api_fetch_reports(request: FetchReportsRequest):
    try:
        reports = fetch_reports(request.user_id)
        return {"status": "success", "reports": reports}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class EditReportRequest(BaseModel):
    report_id: int
    report_data: Dict[str, Any]

@app.post("/api/reports/edit")
async def api_edit_report(request: EditReportRequest):
    try:
        result = edit_report(request.report_id, request.report_data)
        return result
    except Exception as e:
        return {"status": "error", "message": str(e)}

class DeleteReportRequest(BaseModel):
    report_id: int

@app.post("/api/reports/delete")
async def api_delete_report(request: DeleteReportRequest):
    try:
        result = delete_report(request.report_id)
        return result
    except Exception as e:
        return {"status": "error", "message": str(e)}

class ProductSearchRequest(BaseModel):
    query: str

@app.post("/api/products/search")
async def api_search_products(request: ProductSearchRequest):
    try:
        products = search_products(request.query)
        return {"status": "success", "products": products}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class ProductFetchRequest(BaseModel):
    status: str
    limit: Optional[int] = 50
    offset: Optional[int] = 0

@app.post("/api/products/fetch")
async def api_fetch_products(request: ProductFetchRequest):
    try:
        products = fetch_products_by_status(request.status, request.limit, request.offset)
        return {"status": "success", "products": products}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/")
async def root():
    return {"message": "Welcome to the NPRA Cosmetics API. Database and auth endpoints are active."}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
