import os
import re
from fastapi import FastAPI, File, UploadFile, Depends
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from database import Base, engine, get_db
from crud import create_bill
from models import Bill
from PIL import Image, ImageEnhance, ImageFilter
import pytesseract

pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Simple OCR API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def preprocess_image_for_ocr(image_path):
    """Simple image preprocessing for better OCR accuracy"""
    image = Image.open(image_path)
    
    # Convert to grayscale if not already
    if image.mode != 'L':
        image = image.convert('L')
    
    # Enhance contrast for better text recognition
    enhancer = ImageEnhance.Contrast(image)
    image = enhancer.enhance(1.5)
    
    # Slightly enhance brightness
    enhancer = ImageEnhance.Brightness(image)
    image = enhancer.enhance(1.1)
    
    # Apply sharpening filter
    image = image.filter(ImageFilter.SHARPEN)
    
    # Resize if image is too small (helps OCR)
    width, height = image.size
    if width < 600 or height < 600:
        scale_factor = max(600/width, 600/height)
        new_size = (int(width * scale_factor), int(height * scale_factor))
        image = image.resize(new_size, Image.Resampling.LANCZOS)
    
    return image

@app.post("/ocr")
async def simple_ocr(file: UploadFile = File(...), db: Session = Depends(get_db)):
    """Simple OCR endpoint that just extracts all text from image"""
    try:
        # Save uploaded file
        file_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)

        # Preprocess image for better OCR
        processed_img = preprocess_image_for_ocr(file_path)
        
        # Try different OCR configurations to get the best text extraction
        configs = [
            '--oem 3 --psm 4',   # Single column of text (good for receipts)
            '--oem 3 --psm 6',   # Uniform block of text
            '--oem 3 --psm 3',   # Fully automatic page segmentation
        ]
        
        best_text = ""
        best_score = 0
        
        for config in configs:
            try:
                # Extract text using this configuration
                text = pytesseract.image_to_string(processed_img, config=config)
                
                # Score based on text length and readability
                score = len(text.strip())
                # Bonus for having numbers (bills usually have amounts)
                score += len(re.findall(r'\d', text)) * 2
                # Bonus for having common words
                common_words = ['total', 'amount', 'tax', 'service', 'bill', 'receipt', 'date', 'time']
                for word in common_words:
                    if word.lower() in text.lower():
                        score += 10
                
                if score > best_score:
                    best_score = score
                    best_text = text
                    
            except Exception as e:
                print(f"Error with config {config}: {e}")
                continue

        # Save to database (you can modify this part based on your needs)
        if best_text.strip():
            db_bill = create_bill(db, best_text, None, None, None)  # Just save the text
        
        # Clean up uploaded file
        os.remove(file_path)
        
        return JSONResponse(content={
            "extracted_text": best_text,
            "text_length": len(best_text),
            "success": True
        })
        
    except Exception as e:
        # Clean up file in case of error
        if 'file_path' in locals() and os.path.exists(file_path):
            os.remove(file_path)
        
        print(f"Error processing OCR: {str(e)}")
        return JSONResponse(content={"error": str(e), "success": False}, status_code=500)

@app.post("/ocr/debug")
async def debug_ocr(file: UploadFile = File(...)):
    """Debug endpoint to test different OCR configurations"""
    try:
        file_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)

        # Process image
        processed_img = preprocess_image_for_ocr(file_path)
        
        # Test different configurations
        configs = [
            ('--oem 3 --psm 3', 'Fully automatic page segmentation'),
            ('--oem 3 --psm 4', 'Single column of text'),
            ('--oem 3 --psm 6', 'Uniform block of text'),
            ('--oem 3 --psm 8', 'Treat as single word'),
            ('--oem 3 --psm 11', 'Sparse text'),
            ('--oem 3 --psm 12', 'Sparse text with OSD'),
        ]
        
        results = {}
        
        for config, description in configs:
            try:
                text = pytesseract.image_to_string(processed_img, config=config)
                
                results[description] = {
                    "config": config,
                    "extracted_text": text,
                    "text_length": len(text),
                    "word_count": len(text.split()),
                    "number_count": len(re.findall(r'\d', text)),
                    "has_content": len(text.strip()) > 0
                }
                
            except Exception as e:
                results[description] = {"error": str(e)}

        # Clean up
        os.remove(file_path)
        
        return JSONResponse(content={"ocr_results": results})
        
    except Exception as e:
        if 'file_path' in locals() and os.path.exists(file_path):
            os.remove(file_path)
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.post("/ocr/raw")
async def raw_ocr(file: UploadFile = File(...)):
    """Raw OCR with minimal processing - just extract text as-is"""
    try:
        file_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)

        # Load image with minimal processing
        image = Image.open(file_path)
        
        # Simple OCR extraction
        text = pytesseract.image_to_string(image)
        
        # Clean up
        os.remove(file_path)
        
        return JSONResponse(content={
            "raw_extracted_text": text,
            "text_length": len(text),
            "success": True
        })
        
    except Exception as e:
        if 'file_path' in locals() and os.path.exists(file_path):
            os.remove(file_path)
        return JSONResponse(content={"error": str(e), "success": False}, status_code=500)