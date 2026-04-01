# Analytics Tracking Plan (Fixawy)

This document outlines the core user events to track via Firebase Analytics (and optionally Mixpanel/Amplitude) to monitor user behavior, detect operational drop-off rates, and optimize the overall marketplace.

---

## 1. Crucial Funnels to Monitor
Before listing individual events, these are the business-critical flows you must construct in your analytics tool:
1. **Booking Funnel:** `service_selected` → `job_requested` → `job_matched`. *(Drop-offs here mean a lack of supply/technicians or customers being too far outside the initial operational zone).*
2. **Invoicing Funnel:** `invoice_viewed` → `invoice_approved` → `checkout_completed`. *(High rejection rates here indicate prices are too high or technicians are inflating material costs, damaging trust).*
3. **Onboarding Funnel:** `sign_up_start` → `otp_requested` → `sign_up_complete`. *(Identifies SMS delivery failures and OTP abandonment).*

---

## 2. Authentication & Onboarding
| Event Name | Trigger | Key Parameters |
| :--- | :--- | :--- |
| `sign_up_start` | User opens the app for the very first time | `platform` (ios/android), `app_version` |
| `otp_requested` | User inputs phone number and taps "Send OTP" | `phone_prefix` (e.g., +2010) |
| `sign_up_complete` | User successfully verifies OTP | `role` (customer/tech) |
| `kyc_submitted` | Technician submits required ID photos | `specialty` |

---

## 3. Customer Journey (Tier 1 Repair)
| Event Name | Trigger | Key Parameters |
| :--- | :--- | :--- |
| `service_selected` | Customer taps a category card (e.g., Plumbing) | `service_category` |
| `job_requested` | Customer presses "Request Emergency Tech" | `service_category`, `has_voice_note` (boolean), `zone` |
| `job_matched` | A technician successfully accepts the request | `job_id`, `wait_time_seconds` |
| `invoice_viewed` | Digital receipt modal successfully loads for client| `job_id`, `total_amount`, `materials_cost` |
| `invoice_approved` | Customer taps "Approve & Start Work" | `job_id` |
| `invoice_rejected` | Customer taps "Reject" | `job_id`, `reason` |
| `checkout_completed` | Payment loop closed successfully | `job_id`, `payment_method` (cash/card), `amount` |
| `job_rated` | Customer submits post-job rating | `job_id`, `stars` (1-5) |

---

## 4. Technician Journey
| Event Name | Trigger | Key Parameters |
| :--- | :--- | :--- |
| `tech_went_online` | Technician toggles the switch to "Online" | `current_zone`, `battery_level` |
| `job_ping_received` | Incoming job alert strikes the technician's app| `job_id`, `distance_km`, `service_category` |
| `job_accepted` | Tech swipes the slider to ACCEPT the job | `job_id`, `response_time_seconds` |
| `job_ignored` | Countdown timer hits 0 without a swipe | `job_id` |
| `arrived_at_location`| Tech taps "I Have Arrived" at customer's house| `job_id`, `travel_time_minutes` |
| `invoice_submitted` | Tech finishes live photo and sets material cost | `job_id`, `materials_cost`, `labor_cost` |
| `panic_button_pressed`| Tech taps the shield/panic flag icon | `job_id`, `current_status` |

---

## 5. System Architecture Health
*These should ideally be logged as non-fatal errors in Crashlytics as well.*
| Event Name | Trigger | Key Parameters |
| :--- | :--- | :--- |
| `camera_load_failed` | Technically failed to mount the live camera | `device_model`, `os_version` |
| `offline_sync_triggered`| Tech closed a job while offline, sync queued | `job_id` |
| `payment_gateway_error` | Paymob returns an error on credit card process| `error_code`, `amount` |
