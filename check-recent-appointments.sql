-- Check recent appointments from appointments-app
SELECT
    a.id,
    a.appointment_id,
    a.status,
    a.scheduled_at,
    a.source,
    a.confirmation_date,
    a.created_at,
    p.first_name,
    p.last_name,
    p.is_confirmed as patient_confirmed,
    d.name as doctor_name
FROM appointments a
LEFT JOIN patients p ON p.id = a.patient_id
LEFT JOIN doctors d ON d.id = a.doctor_id
WHERE a.hospital_id = '550e8400-e29b-41d4-a716-446655440000'
ORDER BY a.created_at DESC
LIMIT 10;

-- Check if there are any unconfirmed appointments
SELECT
    COUNT(*) as unconfirmed_count
FROM appointments
WHERE confirmation_date IS NULL
AND hospital_id = '550e8400-e29b-41d4-a716-446655440000';

-- Check appointments scheduled for today and future
SELECT
    a.id,
    a.appointment_id,
    a.status,
    a.scheduled_at,
    a.source,
    p.first_name || ' ' || p.last_name as patient_name,
    d.name as doctor_name
FROM appointments a
LEFT JOIN patients p ON p.id = a.patient_id
LEFT JOIN doctors d ON d.id = a.doctor_id
WHERE a.hospital_id = '550e8400-e29b-41d4-a716-446655440000'
AND a.scheduled_at >= NOW()
ORDER BY a.scheduled_at ASC
LIMIT 20;
