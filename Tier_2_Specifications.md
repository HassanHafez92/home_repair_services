# Tier 2 Specifications: Architectural & General Contracting

This document outlines the scope, screens, and database structures required to support the "Tier 2" business model (high-end residential finishing, B2B clinical fit-outs, and architectural general contracting). Unlike Tier 1 (Emergency Dispatch), Tier 2 operates on a **Consultative / Milestone** workflow.

---

## 1. The Core Workflow (Consultative Process)

1. **Request for Quotation (RFQ):** The customer inputs their project details (photos, dimensions, desired style).
2. **Initial Consultation (Chat/Call):** A dedicated internal Project Manager (PM) reaches out via the Admin Dashboard to clarify scope.
3. **Proposal & 3D Design Approval:** Admins upload a PDF proposal, 3D renders, and a milestone payment plan. The customer reviews and approves this in the app.
4. **Milestone Execution & Payment:** The project is split into phases (e.g., Demolition, Plumbing, Painting, Handover). The customer pays unlocking each milestone sequentially.
5. **Final Handover & Warranty:** Final walkthrough scheduled in-app. Once matched, the warranty period activates.

---

## 2. Customer App Screen Inventory (Tier 2 Addition)

| Screen Name | Primary Function | Required UI Components |
| :--- | :--- | :--- |
| **1. Dedicated "Projects" Tab** | Landing portal for high-ticket renovations. | Distinct premium UI (dark mode or gold accents) separate from Tier 1 emergencies. "Start a Renovation" CTA. |
| **2. RFQ Builder / Onboarding** | Gathering initial project scope. | Step-by-step wizard: Select Property Type (Clinic/Home), Input Square Meters, Upload current photos, Select Design Style (Modern, Neoclassic), Budget range slider. |
| **3. Project Dashboard (Active)** | Tracking a live renovation project. | Top progress bar showing current milestone (e.g., "Phase 2/5: Plumbing"). A horizontal carousel to view 3D renders vs. Real-Time progress photos. Chat icon to contact the PM. |
| **4. Approvals & Proposals** | Viewing and legally accepting quotes. | PDF/Image viewer for floor plans and 3D designs. A detailed ledger of the total cost breakdown, and a massive "Sign & Accept Proposal" button triggering an e-signature or OTP confirmation. |
| **5. Milestone Checkout** | Processing large sum fractional payments. | Display of locked vs. unlocked milestones. A "Pay Milestone X" button integrating with Paymob (Cards, Installments via ValU/Sympl, or Bank Transfer instructions for very large sums). |

---

## 3. Technician App Changes (For "Elite" Subcontractors)

*The standard Technician App won't see Tier 2 jobs natively. However, highly-rated technicians promoted to "Elite" status can receive segmented milestone tasks.*

| Screen Name | Primary Function | Required UI Components |
| :--- | :--- | :--- |
| **1. Subcontractor Board** | Receiving multi-day project tasks. | A separate tab for "Scheduled Projects." Shows start date, end date, and exact daily deliverables requested by the platform's Project Manager. |
| **2. Daily Progress Upload** | Guaranteeing quality control to the PM. | A mandatory daily requirement to upload wide-angle photos of the finished room to unlock their daily/weekly payout from the Admin Dashboard. |

---

## 4. Admin Dashboard (Project Management Module)

*This is the heaviest technical addition for Tier 2, essentially functioning as a mini Construction CRM.*

| Feature Module | Primary Function | Capabilities |
| :--- | :--- | :--- |
| **1. RFQ Triage Board** | Managing incoming project leads. | Kanban board (New Lead → Contacted → Designing → Quoting → Contract Sent → Active). |
| **2. Proposal Generator** | Sending structured quotes to the app. | Admins can upload PDFs, 3D images, and define a dynamic array of pricing milestones (e.g., "Milestone 1: 20% - 150,000 EGP"). |
| **3. Multi-Tech Dispatch** | Assigning labor to milestones. | Admins can manually drag-and-drop 3 plumbers, 2 electricians, and 1 painter to a specific project site for specific dates. |

---

## 5. Database Schema Additions (Firestore)

**New Collection: `projects` (Tier 2 Jobs)**
* `projectId`, `customerId`, `assignedPmId`
* `status` (rfq_submitted, quoting, awaiting_customer_approval, active, completed, cancelled)
* `budgetRange`, `propertyType`, `squareMeters`
* `proposals[]` (URL links to documents and 3D renders)
* `milestones[]`:
    * `milestoneId`, `title`, `amount`, `status` (locked, pending_payment, paid, completed)
* `createdAt`, `updatedAt`

**New Collection: `project_chat`**
* Internal messaging strictly between the `customerId` and the Admin's `assignedPmId` to isolate complex project discussions from standard Tier 1 tracking.
