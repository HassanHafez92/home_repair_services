Here is the comprehensive UI/UX Handoff Brief for the MVP, translated into English and ready to be fed into your design tools or handed over to a UI/UX designer:

# ---

**UI/UX Handoff Brief \- MVP**

**Project:** Home Repair App (Emergency & Rapid Response Edition)

**Target Platforms:** Mobile (iOS & Android)

**Visual Style:** Clean, responsive, trustworthy, and action-oriented.

## **1\. Global Design Guidelines**

Before designing the individual screens, the following global elements must be established:

* **Global States:** Design the Loading Spinners, Offline/No Connection states, and Empty States (e.g., when a user has no prior job history).  
* **Color Palette (Functional):**  
  * **Primary Actions:** Clear, high-contrast colors (e.g., Deep Blue or vibrant Orange) to encourage clicks.  
  * **Emergency & Cancellation:** Distinct Red.  
  * **Success & Approvals:** Distinct Green.  
* **Typography:** Clean, modern, sans-serif fonts that are highly legible on small screens (e.g., Inter, Roboto, or SF Pro).

## ---

**2\. Customer App Screen Inventory**

| Screen Name | Primary Function | Required UI Components |
| :---- | :---- | :---- |
| **1\. Auth Screen** | Quick and secure login. | App logo, "Continue with Google" button, Phone number input field, "Send OTP" button, and 4-6 digit OTP input fields. |
| **2\. Home Dashboard** | Guiding the customer to book a service. | Welcome message, top search bar, prominent Service Cards for MVP (Plumbing, Electrical, AC), and a Bottom Navigation bar. |
| **3\. Emergency Booking (Map)** | Location pinning and problem description. | **Top Half:** Interactive Google Map with a draggable location pin. **Bottom Half:** Large "Record Voice Note" icon, and a prominent "Request Emergency Tech Now" Call-to-Action (CTA) button. |
| **4\. Live Tracking** | Reassuring the customer and tracking the tech. | Live map showing the technician's vehicle/icon moving. A bottom sheet containing: Technician’s photo, name, rating, vehicle plate number, a "Call" icon, and Estimated Time of Arrival (ETA). |
| **5\. Digital Receipt (Modal)** | Cost approval before work begins. | A sudden Pop-up/Modal containing: Detailed pricing table (Inspection Fee, Labor, Materials), automatic subtraction of the Inspection Fee, Total Amount Due, and two buttons: "Approve & Start Work" (Green) and "Reject" (Red). |
| **6\. Checkout & Rating** | Closing the financial loop and quality control. | UI to select payment method (Cash or Credit Card via Paymob), followed by a Success State screen, and a 5-star rating system with an optional text field for reviews. |

## ---

**3\. Technician App Screen Inventory**

| Screen Name | Primary Function | Required UI Components |
| :---- | :---- | :---- |
| **1\. Onboarding & KYC** | Collecting security and technical documents. | Basic info input fields, dedicated buttons to open the camera for taking photos of ID (Front/Back) and Criminal Record, and a drop-down menu to select their specialty. |
| **2\. Tech Dashboard** | Managing availability and tracking earnings. | Prominent top toggle switch (Online/Offline), a numerical summary of weekly earnings, average star rating, and a button to access the "Wallet." |
| **3\. Incoming Job Ping** | Alerting the tech to a new request. | Full-Screen Alert with visual ringing. Displays: Requested service type, distance in kilometers, a circular countdown timer (e.g., 30 seconds), and a "Swipe to Accept" slider. |
| **4\. Job Execution** | Guiding the tech to the site and problem info. | Mini-map, customer's text address, audio player (to listen to the customer's voice note), and an "Open in Google Maps" routing button. An "I Have Arrived" button appears once they are near the location. |
| **5\. Invoicing & Live Camera** | Protecting material quality and issuing quotes. | Drop-down menu to select labor items (prices are fixed/locked), an input field for the total cost of materials. **Mandatory element:** A large square button that opens the live camera to capture the material receipt (Gallery access disabled). "Send to Customer" button. |
| **6\. Wallet & Clearing** | Displaying debts and earnings accurately. | Top card showing current balance (Green for earnings, Red for debt to the app), a Credit Limit Progress Bar, and a bottom List View showing the historical transaction ledger for every job. |

## ---

**4\. Strict UI/UX Constraints (For Designers & Developers)**

1. **Live Camera Lock:** On the Technician's Invoicing screen (Screen 5), the user must not be able to complete the invoice without taking a *live photo* of the materials used. The gallery upload option must be visually and functionally disabled.  
2. **Pricing Isolation:** On the same screen, when the technician selects a service (e.g., "Replace Valve"), the system auto-populates the price based on the database. The price input field must be strictly "Read-Only" and cannot be manually edited by the tech.  
3. **Panic/Dispute Button:** In the Technician App, a small icon (e.g., an exclamation mark or a shield) must be present in the corner of the screen during the "Job Execution" phase. This allows the tech to immediately report issues like "Customer Refuses to Pay" to the Admin dashboard.