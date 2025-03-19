CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    contact_info VARCHAR(100),
    address VARCHAR(255)
);

INSERT INTO Patients (patient_id, name, dob, contact_info, address) VALUES
(1, 'Alice Smith', '1990-04-05', '123-456-7890', '123 Main St'),
(2, 'Bob Johnson', '1985-06-12', '234-567-8901', '456 Oak St'),
(3, 'Carol White', '1998-02-22', '345-678-9012', '789 Pine St'),
(4, 'David Brown', '2002-08-17', '456-789-0123', '101 Maple St');

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialty VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100)
);

INSERT INTO Doctors (doctor_id, name, specialty, phone, email) VALUES
(1, 'Dr. John Doe', 'Cardiology', '555-1234', 'johndoe@clinic.com'),
(2, 'Dr. Emma Taylor', 'Pediatrics', '555-5678', 'emmataylor@clinic.com'),
(3, 'Dr. Michael Lee', 'Orthopedics', '555-8765', 'michaellee@clinic.com'),
(4, 'Dr. Sarah Green', 'Dermatology', '555-4321', 'sarahgreen@clinic.com');


CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status) VALUES
(1, 1, 1, '2024-01-10', 'Completed'),
(2, 2, 1, '2024-02-15', 'Completed'),
(3, 3, 3, '2024-03-10', 'Completed'),
(4, 1, 3, '2024-03-25', 'Completed'),
(5, 4, 2, '2024-04-05', 'Canceled'),
(6, 3, 2, '2024-04-10', 'Completed');

CREATE TABLE MedicalRecords (
    record_id INT PRIMARY KEY,
    patient_id INT,
    notes TEXT,
    diagnosis VARCHAR(255),
    record_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

INSERT INTO MedicalRecords (record_id, patient_id, notes, diagnosis, record_date) VALUES
(1, 1, 'Annual checkup', 'Healthy', '2024-01-10'),
(2, 2, 'Heart checkup', 'Hypertension', '2024-02-15'),
(3, 3, 'Knee pain', 'Arthritis', '2024-03-10'),
(4, 1, 'Follow-up knee pain', 'Improved', '2024-03-25');

CREATE TABLE Prescriptions (
    prescription_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    medication VARCHAR(100),
    dosage VARCHAR(50),
    prescription_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

INSERT INTO Prescriptions (prescription_id, patient_id, doctor_id, medication, dosage, prescription_date) VALUES
(1, 1, 1, 'Aspirin', '100 mg', '2024-01-10'),
(2, 2, 1, 'Lisinopril', '10 mg', '2024-02-15'),
(3, 3, 3, 'Ibuprofen', '200 mg', '2024-03-10'),
(4, 1, 3, 'Paracetamol', '500 mg', '2024-03-25');

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    appointment_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE,
    payment_method VARCHAR(50),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

INSERT INTO Payments (payment_id, appointment_id, amount, payment_date, payment_method) VALUES
(1, 1, 100.00, '2024-01-10', 'Credit Card'),
(2, 2, 150.00, '2024-02-15', 'Cash'),
(3, 3, 200.00, '2024-03-10', 'Credit Card'),
(4, 4, 120.00, '2024-03-25', 'Debit Card');

--1) Retrieve a list of patients who have had an appointment with a doctor specializing in "Cardiology".
SELECT DISTINCT Patients.name AS patient_name
FROM Patients
JOIN Appointments ON Patients.patient_id = Appointments.patient_id
JOIN Doctors ON Appointments.doctor_id = Doctors.doctor_id
WHERE Doctors.specialty = 'Cardiology';

--2)Create a list of all patients and doctors along with their names and a designation ("Patient" or "Doctor").
SELECT name AS person_name, 'Patient' AS designation FROM Patients
UNION ALL
SELECT name AS person_name, 'Doctor' AS designation FROM Doctors;

--3)Retrieve each doctor’s name and the average number of appointments per month.
SELECT Doctors.name AS doctor_name,
       COUNT(Appointments.appointment_id) / 
       (DATEDIFF(MONTH, MIN(Appointments.appointment_date), MAX(Appointments.appointment_date)) + 1) AS avg_appointments_per_month
FROM Doctors
JOIN Appointments ON Doctors.doctor_id = Appointments.doctor_id
GROUP BY Doctors.name;

--4)Retrieve each patient’s name along with their most recent diagnosis.
SELECT Patients.name AS patient_name, MedicalRecords.diagnosis
FROM Patients
JOIN MedicalRecords ON Patients.patient_id = MedicalRecords.patient_id
WHERE MedicalRecords.record_date = (
    SELECT MAX(record_date)
    FROM MedicalRecords AS MR
    WHERE MR.patient_id = Patients.patient_id
);

--5)Create a combined list of patients and doctors who are either under 30 (patients) or specialize in "Pediatrics" (doctors).
SELECT name, 'Patient' AS designation FROM Patients
WHERE DATEDIFF(YEAR, dob, GETDATE()) < 30
UNION
SELECT name, 'Doctor' AS designation FROM Doctors
WHERE specialty = 'Pediatrics';

--6)List all doctors who have more than 20 completed appointments.
SELECT Doctors.name AS doctor_name
FROM Doctors
JOIN Appointments ON Doctors.doctor_id = Appointments.doctor_id
WHERE Appointments.status = 'Completed'
GROUP BY Doctors.name
HAVING COUNT(Appointments.appointment_id) > 20;

--7)Find all patients who have at least one prescription for "Ibuprofen" issued by a doctor specializing in "Orthopedics".
SELECT DISTINCT Patients.name AS patient_name
FROM Patients
JOIN Prescriptions ON Patients.patient_id = Prescriptions.patient_id
JOIN Doctors ON Prescriptions.doctor_id = Doctors.doctor_id
WHERE Prescriptions.medication = 'Ibuprofen' AND Doctors.specialty = 'Orthopedics';

--8)Find patients who share the same doctor.
SELECT p1.name AS patient1, p2.name AS patient2, Doctors.name AS shared_doctor
FROM Appointments AS a1
JOIN Appointments AS a2 ON a1.doctor_id = a2.doctor_id AND a1.patient_id < a2.patient_id
JOIN Patients AS p1 ON a1.patient_id = p1.patient_id
JOIN Patients AS p2 ON a2.patient_id = p2.patient_id
JOIN Doctors ON a1.doctor_id = Doctors.doctor_id;

SELECT doctor_id, GROUP_CONCAT(patient_id) AS patients FROM Appointments GROUP BY doctor_id HAVING COUNT(DISTINCT patient_id) > 1;

STRING_AGG(patient_id, ', ') AS patients

--9)Calculate the average payment amount per appointment.
SELECT AVG(amount) AS avg_payment_per_appointment
FROM Payments;

--10)Retrieve each doctor's name and the date of their most recent appointment.
SELECT Doctors.name AS doctor_name, MAX(Appointments.appointment_date) AS most_recent_appointment
FROM Doctors
JOIN Appointments ON Doctors.doctor_id = Appointments.doctor_id
GROUP BY Doctors.name;

