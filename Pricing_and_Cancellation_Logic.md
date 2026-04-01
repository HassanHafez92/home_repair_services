# Pricing & Cancellation Logic (Master Algorithms)

This document details the exact mathematical rules, surge algorithms, cancellation grace periods, and penalty mechanics for the Fixawy platform. It serves as the primary reference for Backend Engineers developing Cloud Functions and Finance/Admin modules.

---

## 1. Base Pricing Structure

Every job processed through the platform consists of three main components:

**1. Inspection Fee (Visita):**
* **Cost:** Fixed base rate (e.g., 150 EGP).
* **Rule:** If the customer proceeds with the repair, the Inspection Fee is *subtracted/waived* from the final labor cost. If they reject the repair after inspection, they only pay the Inspection Fee.

**2. Standardized Labor (Menu Pricing):**
* **Cost:** Server-controlled fixed rate per task (e.g., "Replace Valve" = 200 EGP).
* **Rule:** Technicians cannot edit this out in the field. Selected via pre-defined UI dropdowns.

**3. Materials (Pass-through + Convenience Fee):**
* **Cost:** Exactly what is on the physical store receipt + `X%` Convenience Fee (e.g., 5%).
* **Rule:** Dynamic and inputted manually by the technician, backed by a mandatory live photo of the receipt. If cost > 500 EGP, requires explicit customer approval via push notification before purchase.

***Total Invoice Amount = (Labor Cost - Inspection Fee) + (Materials Cost * 1.05)***

---

## 2. Surge Pricing Engine

Surge pricing is an automated multiplier applied to both the **Inspection Fee** and **Labor Cost** (Materials remain strictly at receipt cost + fixed convenience fee).

### A. Time-Based Surge (Late Night Emergency)
* **Standard Hours (08:00 AM - 10:00 PM):** 1.0x Multiplier (Base Rates).
* **Night Owl (10:00 PM - 02:00 AM):** 1.5x Multiplier.
* **Deep Night/Graveyard (02:00 AM - 08:00 AM):** 2.0x Multiplier.

### B. High-Demand/Low-Supply Surge (Automated Load Balancing)
If the ratio of `active_technicians_in_zone` to `pending_requests_in_zone` drops below an acceptable threshold (e.g., < 0.2):
* A dynamic multiplier (+0.2x to +1.0x) is layered on top of the base algorithm until supply stabilizes.

### C. Holiday Surge
* Pre-configured calendar days (e.g., Eid, major national holidays) trigger an automatic flat **1.5x Multiplier** globally.

---

## 3. Cancellation Policy & Grace Periods

To protect both technicians and customers, strict windows define when and how much is penalized.

### A. Customer Cancellation Matrix

| Cancellation Time | Penalty Amount | Action Taken |
| :--- | :--- | :--- |
| **0 - 5 Minutes** (after tech accepts) | **0 EGP (Free)** | Job cancelled, tech becomes available again. |
| **5+ Minutes** (while tech is en route) | **50 EGP (Late Fee)** | Subtracted from customer wallet balance. Paid into Risk Fund. |
| **After Tech Arrives** | **150 EGP (Full Inspection Fee)** | Added as debt to customer. Paid directly to Technician for wasted travel time. |

### B. Technician Cancellation Matrix

| Cancellation Time | Penalty Amount | Action Taken / Impact |
| :--- | :--- | :--- |
| **0 - 2 Minutes** (Accidental Accept) | **0 EGP (Free)** | Job goes back into the queue for other technicians. |
| **2+ Minutes / En Route** | **-5 Rating Impact & Warning** | Drops their average rating. 3 warnings = Account Suspension. |
| **After Arriving (No-show or refusal to work)** | **-100 EGP + Suspension Review** | Heavily penalized. Amount taken from Tech Wallet to compensate customer. |

---

## 4. Dispute & Risk Fund Mechanics (The "Panic" Button)

When a technician arrives, completes the work, and the customer refuses to pay (or behaves aggressively), the technician triggers a **Panic/Dispute**.

### Immediate Workflow:
1. **Customer Account:** Immediately locked/frozen pending investigation. The disputed amount is recorded as negative debt (`-amount`) in their wallet.
2. **Technician Account:** The technician is instantly compensated for their labor and the materials they bought out-of-pocket directly from the **Platform Risk Fund**. 
3. **Admin Dashboard:** A high-priority ticket is created. Admins review voice notes, GPS telemetry (verifying tech arrived and stayed), and the invoice submission time.

### Resolution Guidelines:
* **Tech At Fault (e.g., damaged property):** Risk Fund takes the loss. Customer debt is cleared. Customer is unbanned. Tech is suspended/fined.
* **Customer At Fault (e.g., simply dodged payment):** Debt remains on the customer's account. They cannot use the app again or register with that phone number until the debt of the disputed amount is settled via Paymob top-up. The Risk Fund absorbed the cost initially to protect the tech.
