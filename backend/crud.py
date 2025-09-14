from sqlalchemy.orm import Session
from models import Bill

def create_bill(db: Session, raw_text: str, total_amount: float = None, tax: float = None, other_charges: float = None):
    db_bill = Bill(
        raw_text=raw_text,
        total_amount=total_amount,
        tax=tax,
        other_charges=other_charges
    )
    db.add(db_bill)
    db.commit()
    db.refresh(db_bill)
    return db_bill
