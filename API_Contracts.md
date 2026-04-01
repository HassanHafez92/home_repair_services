# API Contracts & Data Structures (Fixawy)

This document details the exact JSON payloads used when communicating with the Firebase Cloud Functions layer. It serves as a direct technical reference for both Mobile Frontend Engineers and Backend Engineers.

---

## 1. Customer Dispatch (Request Emergency Tech)
**Endpoint:** `createJobRequest`  
**Trigger:** The customer confirms their location on the map and taps "Request Emergency Tech Now" (with or without a voice note).  

**Request Payload:**
```json
{
  "customerId": "uid_12345",
  "serviceCategory": "plumbing",
  "location": {
    "latitude": 30.12345,
    "longitude": 31.54321
  },
  "addressText": "Building 5, Street 10, Nozha 2",
  "voiceNoteUrl": "gs://fixawy-app-production.appspot.com/voice_notes/uid_12345_123.mp3"
}
```

**Response (Success):**
```json
{
  "status": "success",
  "data": {
    "jobId": "job_9876",
    "status": "searching",
    "inspectionFee": 150
  }
}
```

---

## 2. Technician Response (Accept Job)
**Endpoint:** `acceptJob`  
**Trigger:** The technician swipes the "Swipe to Accept" slider on the incoming Job Ping screen.

**Request Payload:**
```json
{
  "jobId": "job_9876",
  "technicianId": "tech_uid_555"
}
```

---

## 3. Tech Invoicing (Create Receipt)
**Endpoint:** `submitInvoice`  
**Trigger:** The technician inputs required labor, the overall cost of materials, takes a live receipt photo, and taps "Send to Customer".

**Request Payload:**
```json
{
  "jobId": "job_9876",
  "technicianId": "tech_uid_555",
  "laborItems": [
    {
      "itemId": "valve_replacement",
      "description": "Replace Water Valve",
      "amount": 200
    }
  ],
  "materialsCost": 450.0,
  "receiptImageUrl": "gs://fixawy-app-production.appspot.com/receipts/job_9876.jpg"
}
```

---

## 4. Customer Invoice Approval
**Endpoint:** `respondToInvoice`  
**Trigger:** The customer taps "Approve & Start Work" (Green) or "Reject" (Red) on the digital receipt modal.

**Request Payload:**
```json
{
  "jobId": "job_9876",
  "customerId": "uid_12345",
  "approved": true,
  "disputeReason": "" // Only populated if approved is false
}
```

---

## 5. Checkout / Payment Completion
**Endpoint:** `completeJobPayment`  
**Trigger:** The system receives a Paymob Webhook (for cards) or the technician physically logs that cash was received.

**Request Payload (Cash Logging Example):**
```json
{
  "jobId": "job_9876",
  "paymentMethod": "cash",
  "amountCollected": 650.0
}
```

---

## 6. Panic/Dispute
**Endpoint:** `raiseDispute`  
**Trigger:** The technician clicks the Panic/Shield icon during job execution (e.g., if the customer refuses to pay or is aggressive).

**Request Payload:**
```json
{
  "jobId": "job_9876",
  "reportedBy": "tech_uid_555",
  "reason": "customer_refused_payment",
  "notes": "Customer aggressive and refuses to pay 650 EGP after work completed."
}
```
