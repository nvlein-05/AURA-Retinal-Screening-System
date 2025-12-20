-- =====================================================
-- AURA Retinal Screening System Database Schema
-- System: SP26SE025
-- Database: PostgreSQL
-- Version: 2.0 (Final - Optimized and Reorganized)
-- Created: 2025
-- =====================================================

-- =====================================================
-- DROP TABLES (Reverse dependency order)
-- =====================================================

DROP TABLE IF EXISTS exported_reports CASCADE;
DROP TABLE IF EXISTS medical_notes CASCADE;
DROP TABLE IF EXISTS clinic_reports CASCADE;
DROP TABLE IF EXISTS ai_configurations CASCADE;
DROP TABLE IF EXISTS notification_templates CASCADE;
DROP TABLE IF EXISTS bulk_upload_batches CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS payment_history CASCADE;
DROP TABLE IF EXISTS user_packages CASCADE;
DROP TABLE IF EXISTS service_packages CASCADE;
DROP TABLE IF EXISTS annotations CASCADE;
DROP TABLE IF EXISTS ai_feedback CASCADE;
DROP TABLE IF EXISTS analysis_results CASCADE;
DROP TABLE IF EXISTS retinal_images CASCADE;
DROP TABLE IF EXISTS ai_model_versions CASCADE;
DROP TABLE IF EXISTS patient_doctor_assignments CASCADE;
DROP TABLE IF EXISTS clinic_doctors CASCADE;
DROP TABLE IF EXISTS clinic_users CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS admins CASCADE;
DROP TABLE IF EXISTS clinics CASCADE;
DROP TABLE IF EXISTS doctors CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS permissions CASCADE;

-- =====================================================
-- SECTION 1: ROLES AND PERMISSIONS (Foundation)
-- =====================================================

CREATE TABLE roles (
    Id VARCHAR(255) PRIMARY KEY,
    RoleName VARCHAR(255) NOT NULL,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE permissions (
    Id VARCHAR(255) PRIMARY KEY,
    PermissionName VARCHAR(255) NOT NULL UNIQUE,
    PermissionDescription TEXT,
    ResourceType VARCHAR(255),
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE role_permissions (
    Id VARCHAR(255) PRIMARY KEY,
    RoleId VARCHAR(255) NOT NULL REFERENCES roles(Id) ON DELETE CASCADE,
    PermissionId VARCHAR(255) NOT NULL REFERENCES permissions(Id) ON DELETE CASCADE,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UNIQUE(RoleId, PermissionId)
);

-- =====================================================
-- SECTION 2: CORE ENTITIES (Users, Doctors, Clinics, Admins)
-- =====================================================

CREATE TABLE users (
    Id VARCHAR(255) PRIMARY KEY,
    Username VARCHAR(255),
    Password VARCHAR(255),
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Email VARCHAR(255) NOT NULL UNIQUE,
    Dob DATE,
    Phone VARCHAR(255),
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    Address VARCHAR(255),
    City VARCHAR(100),
    Province VARCHAR(100),
    Country VARCHAR(100) DEFAULT 'Vietnam',
    IdentificationNumber VARCHAR(50),
    AuthenticationProvider VARCHAR(50) DEFAULT 'email' CHECK (AuthenticationProvider IN ('email', 'google', 'facebook')),
    ProviderUserId VARCHAR(255),
    ProfileImageUrl VARCHAR(500),
    IsEmailVerified BOOLEAN DEFAULT FALSE,
    IsActive BOOLEAN DEFAULT TRUE,
    LastLoginAt TIMESTAMP,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE doctors (
    Id VARCHAR(255) PRIMARY KEY,
    Username VARCHAR(255),
    Password VARCHAR(255),
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(255),
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    LicenseNumber VARCHAR(100) NOT NULL UNIQUE,
    Specialization VARCHAR(255),
    YearsOfExperience INTEGER,
    ProfileImageUrl VARCHAR(500),
    IsVerified BOOLEAN DEFAULT FALSE,
    IsActive BOOLEAN DEFAULT TRUE,
    LastLoginAt TIMESTAMP,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE clinics (
    Id VARCHAR(255) PRIMARY KEY,
    ClinicName VARCHAR(255) NOT NULL,
    RegistrationNumber VARCHAR(100) UNIQUE,
    TaxCode VARCHAR(50),
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(255),
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(100),
    Province VARCHAR(100),
    Country VARCHAR(100) DEFAULT 'Vietnam',
    WebsiteUrl VARCHAR(500),
    ContactPersonName VARCHAR(255),
    ContactPersonPhone VARCHAR(255),
    ClinicType VARCHAR(50) CHECK (ClinicType IN ('Hospital', 'Clinic', 'Medical Center', 'Other')),
    VerificationStatus VARCHAR(50) DEFAULT 'Pending' CHECK (VerificationStatus IN ('Pending', 'Approved', 'Rejected', 'Suspended')),
    IsActive BOOLEAN DEFAULT TRUE,
    VerifiedAt TIMESTAMP,
    VerifiedBy VARCHAR(255) REFERENCES admins(Id),
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE admins (
    Id VARCHAR(255) PRIMARY KEY,
    Username VARCHAR(255),
    Password VARCHAR(255),
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(255),
    ProfileImageUrl VARCHAR(500),
    RoleId VARCHAR(255) NOT NULL REFERENCES roles(Id),
    IsSuperAdmin BOOLEAN DEFAULT FALSE,
    IsActive BOOLEAN DEFAULT TRUE,
    LastLoginAt TIMESTAMP,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- SECTION 3: RELATIONSHIPS (Junction Tables)
-- =====================================================

CREATE TABLE user_roles (
    Id VARCHAR(255) PRIMARY KEY,
    UserId VARCHAR(255) NOT NULL REFERENCES users(Id) ON DELETE CASCADE,
    RoleId VARCHAR(255) NOT NULL REFERENCES roles(Id) ON DELETE CASCADE,
    IsPrimary BOOLEAN DEFAULT FALSE,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UNIQUE(UserId, RoleId)
);

CREATE TABLE clinic_doctors (
    Id VARCHAR(255) PRIMARY KEY,
    ClinicId VARCHAR(255) NOT NULL REFERENCES clinics(Id) ON DELETE CASCADE,
    DoctorId VARCHAR(255) NOT NULL REFERENCES doctors(Id) ON DELETE CASCADE,
    IsPrimary BOOLEAN DEFAULT FALSE,
    JoinedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UNIQUE(ClinicId, DoctorId)
);

CREATE TABLE clinic_users (
    Id VARCHAR(255) PRIMARY KEY,
    ClinicId VARCHAR(255) NOT NULL REFERENCES clinics(Id) ON DELETE CASCADE,
    UserId VARCHAR(255) NOT NULL REFERENCES users(Id) ON DELETE CASCADE,
    RegisteredAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UNIQUE(ClinicId, UserId)
);

CREATE TABLE patient_doctor_assignments (
    Id VARCHAR(255) PRIMARY KEY,
    UserId VARCHAR(255) NOT NULL REFERENCES users(Id) ON DELETE CASCADE,
    DoctorId VARCHAR(255) NOT NULL REFERENCES doctors(Id) ON DELETE CASCADE,
    ClinicId VARCHAR(255) REFERENCES clinics(Id) ON DELETE SET NULL,
    AssignedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    AssignedBy VARCHAR(255) REFERENCES admins(Id),
    IsActive BOOLEAN DEFAULT TRUE,
    Notes TEXT,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- SECTION 4: AI MODELS (Foundation for Analysis)
-- =====================================================

CREATE TABLE ai_model_versions (
    Id VARCHAR(255) PRIMARY KEY,
    ModelName VARCHAR(255) NOT NULL,
    VersionNumber VARCHAR(50) NOT NULL,
    ModelType VARCHAR(100) NOT NULL,
    Description TEXT,
    ModelPath VARCHAR(500),
    AccuracyMetrics JSONB,
    TrainingDate DATE,
    DeployedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedBy VARCHAR(255) REFERENCES admins(Id),
    CreatedDate DATE,
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE,
    UNIQUE(ModelName, VersionNumber)
);

-- =====================================================
-- SECTION 5: IMAGES & ANALYSIS (Core Business Logic)
-- =====================================================

CREATE TABLE retinal_images (
    Id VARCHAR(255) PRIMARY KEY,
    UserId VARCHAR(255) NOT NULL REFERENCES users(Id) ON DELETE CASCADE,
    ClinicId VARCHAR(255) REFERENCES clinics(Id) ON DELETE SET NULL,
    DoctorId VARCHAR(255) REFERENCES doctors(Id) ON DELETE SET NULL,
    BatchId VARCHAR(255),
    OriginalFilename VARCHAR(255) NOT NULL,
    StoredFilename VARCHAR(255) NOT NULL,
    FilePath VARCHAR(500) NOT NULL,
    CloudinaryUrl VARCHAR(500),
    FileSize BIGINT,
    ImageType VARCHAR(50) CHECK (ImageType IN ('Fundus', 'OCT')),
    ImageFormat VARCHAR(10) CHECK (ImageFormat IN ('JPEG', 'PNG', 'TIFF', 'DICOM')),
    EyeSide VARCHAR(10) CHECK (EyeSide IN ('Left', 'Right', 'Both')),
    UploadStatus VARCHAR(50) DEFAULT 'Uploaded' CHECK (UploadStatus IN ('Uploaded', 'Processing', 'Processed', 'Failed')),
    UploadedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ProcessedAt TIMESTAMP,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE bulk_upload_batches (
    Id VARCHAR(255) PRIMARY KEY,
    ClinicId VARCHAR(255) NOT NULL REFERENCES clinics(Id) ON DELETE CASCADE,
    UploadedBy VARCHAR(255) NOT NULL,
    UploadedByType VARCHAR(20) NOT NULL CHECK (UploadedByType IN ('Doctor', 'Admin', 'ClinicManager')),
    BatchName VARCHAR(255),
    TotalImages INTEGER NOT NULL DEFAULT 0,
    ProcessedImages INTEGER DEFAULT 0,
    FailedImages INTEGER DEFAULT 0,
    ProcessingImages INTEGER DEFAULT 0,
    UploadStatus VARCHAR(50) DEFAULT 'Pending' CHECK (UploadStatus IN ('Pending', 'Uploading', 'Processing', 'Completed', 'Failed', 'PartiallyCompleted')),
    StartedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CompletedAt TIMESTAMP,
    FailureReason TEXT,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

-- Add BatchId foreign key after bulk_upload_batches is created
ALTER TABLE retinal_images ADD CONSTRAINT FK_retinal_images_BatchId 
    FOREIGN KEY (BatchId) REFERENCES bulk_upload_batches(Id) ON DELETE SET NULL;

CREATE TABLE analysis_results (
    Id VARCHAR(255) PRIMARY KEY,
    ImageId VARCHAR(255) NOT NULL REFERENCES retinal_images(Id) ON DELETE CASCADE,
    UserId VARCHAR(255) NOT NULL REFERENCES users(Id) ON DELETE CASCADE,
    ModelVersionId VARCHAR(255) NOT NULL REFERENCES ai_model_versions(Id),
    AnalysisStatus VARCHAR(50) DEFAULT 'Processing' CHECK (AnalysisStatus IN ('Processing', 'Completed', 'Failed', 'Pending')),
    OverallRiskLevel VARCHAR(50) CHECK (OverallRiskLevel IN ('Low', 'Medium', 'High', 'Critical')),
    RiskScore DECIMAL(5,2) CHECK (RiskScore >= 0 AND RiskScore <= 100),
    
    -- Cardiovascular Risk Assessment
    HypertensionRisk VARCHAR(50) CHECK (HypertensionRisk IN ('Low', 'Medium', 'High')),
    HypertensionScore DECIMAL(5,2),
    
    -- Diabetes Risk Assessment
    DiabetesRisk VARCHAR(50) CHECK (DiabetesRisk IN ('Low', 'Medium', 'High')),
    DiabetesScore DECIMAL(5,2),
    DiabeticRetinopathyDetected BOOLEAN DEFAULT FALSE,
    DiabeticRetinopathySeverity VARCHAR(50) CHECK (DiabeticRetinopathySeverity IN ('None', 'Mild', 'Moderate', 'Severe', 'Proliferative')),
    
    -- Stroke Risk Assessment
    StrokeRisk VARCHAR(50) CHECK (StrokeRisk IN ('Low', 'Medium', 'High')),
    StrokeScore DECIMAL(5,2),
    
    -- Vascular Abnormalities
    MicroaneurysmsCount INTEGER DEFAULT 0,
    HemorrhagesDetected BOOLEAN DEFAULT FALSE,
    ExudatesDetected BOOLEAN DEFAULT FALSE,
    
    -- Annotated Image
    AnnotatedImageUrl VARCHAR(500),
    HeatmapUrl VARCHAR(500),
    
    -- AI Confidence
    AiConfidenceScore DECIMAL(5,2) CHECK (AiConfidenceScore >= 0 AND AiConfidenceScore <= 100),
    
    -- Recommendations
    Recommendations TEXT,
    HealthWarnings TEXT,
    
    -- Processing Info
    AnalysisStartedAt TIMESTAMP,
    AnalysisCompletedAt TIMESTAMP,
    
    -- Additional Data
    DetailedFindings JSONB,
    RawAiOutput JSONB,
    
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE annotations (
    Id VARCHAR(255) PRIMARY KEY,
    ResultId VARCHAR(255) NOT NULL REFERENCES analysis_results(Id) ON DELETE CASCADE,
    AnnotationType VARCHAR(50) NOT NULL CHECK (AnnotationType IN ('Vessel', 'Microaneurysm', 'Hemorrhage', 'Exudate', 'Abnormality', 'Other')),
    Coordinates JSONB NOT NULL,
    Description TEXT,
    Severity VARCHAR(50),
    ConfidenceScore DECIMAL(5,2),
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE ai_feedback (
    Id VARCHAR(255) PRIMARY KEY,
    ResultId VARCHAR(255) NOT NULL REFERENCES analysis_results(Id) ON DELETE CASCADE,
    DoctorId VARCHAR(255) NOT NULL REFERENCES doctors(Id) ON DELETE CASCADE,
    FeedbackType VARCHAR(50) NOT NULL CHECK (FeedbackType IN ('Correct', 'Incorrect', 'PartiallyCorrect', 'NeedsReview')),
    OriginalRiskLevel VARCHAR(50),
    CorrectedRiskLevel VARCHAR(50),
    FeedbackNotes TEXT,
    IsUsedForTraining BOOLEAN DEFAULT FALSE,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE medical_notes (
    Id VARCHAR(255) PRIMARY KEY,
    ResultId VARCHAR(255) NOT NULL REFERENCES analysis_results(Id) ON DELETE CASCADE,
    DoctorId VARCHAR(255) NOT NULL REFERENCES doctors(Id) ON DELETE CASCADE,
    NoteType VARCHAR(50) NOT NULL CHECK (NoteType IN ('Diagnosis', 'Recommendation', 'FollowUp', 'General', 'Prescription')),
    NoteContent TEXT NOT NULL,
    Diagnosis VARCHAR(255),
    Prescription TEXT,
    FollowUpDate DATE,
    IsImportant BOOLEAN DEFAULT FALSE,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- SECTION 6: PACKAGES & PAYMENTS (Business Logic)
-- =====================================================

CREATE TABLE service_packages (
    Id VARCHAR(255) PRIMARY KEY,
    PackageName VARCHAR(255) NOT NULL,
    PackageType VARCHAR(50) NOT NULL CHECK (PackageType IN ('Individual', 'Clinic', 'Enterprise')),
    Description TEXT,
    NumberOfAnalyses INTEGER NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Currency VARCHAR(10) DEFAULT 'VND',
    ValidityDays INTEGER,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedBy VARCHAR(255) REFERENCES admins(Id),
    CreatedDate DATE,
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE user_packages (
    Id VARCHAR(255) PRIMARY KEY,
    UserId VARCHAR(255) REFERENCES users(Id) ON DELETE CASCADE,
    ClinicId VARCHAR(255) REFERENCES clinics(Id) ON DELETE CASCADE,
    PackageId VARCHAR(255) NOT NULL REFERENCES service_packages(Id),
    RemainingAnalyses INTEGER NOT NULL,
    PurchasedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ExpiresAt TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE,
    CHECK ((UserId IS NOT NULL AND ClinicId IS NULL) OR (UserId IS NULL AND ClinicId IS NOT NULL))
);

CREATE TABLE payment_history (
    Id VARCHAR(255) PRIMARY KEY,
    UserId VARCHAR(255) REFERENCES users(Id) ON DELETE SET NULL,
    ClinicId VARCHAR(255) REFERENCES clinics(Id) ON DELETE SET NULL,
    PackageId VARCHAR(255) NOT NULL REFERENCES service_packages(Id),
    UserPackageId VARCHAR(255) REFERENCES user_packages(Id) ON DELETE SET NULL,
    PaymentMethod VARCHAR(50) CHECK (PaymentMethod IN ('CreditCard', 'DebitCard', 'BankTransfer', 'E-Wallet', 'Other')),
    PaymentProvider VARCHAR(100),
    TransactionId VARCHAR(255) UNIQUE,
    Amount DECIMAL(10,2) NOT NULL,
    Currency VARCHAR(10) DEFAULT 'VND',
    PaymentStatus VARCHAR(50) DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReceiptUrl VARCHAR(500),
    Notes TEXT,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE,
    CHECK ((UserId IS NOT NULL AND ClinicId IS NULL) OR (UserId IS NULL AND ClinicId IS NOT NULL))
);

-- =====================================================
-- SECTION 7: COMMUNICATION (Messages & Notifications)
-- =====================================================

CREATE TABLE messages (
    Id VARCHAR(255) PRIMARY KEY,
    ConversationId VARCHAR(255) NOT NULL,
    SendById VARCHAR(255) NOT NULL,
    SendByType VARCHAR(20) NOT NULL CHECK (SendByType IN ('User', 'Doctor', 'Admin')),
    ReceiverId VARCHAR(255) NOT NULL,
    ReceiverType VARCHAR(20) NOT NULL CHECK (ReceiverType IN ('User', 'Doctor', 'Admin')),
    Subject VARCHAR(255),
    Content TEXT NOT NULL,
    AttachmentUrl VARCHAR(500),
    IsRead BOOLEAN DEFAULT FALSE,
    ReadAt TIMESTAMP,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE notifications (
    Id VARCHAR(255) PRIMARY KEY,
    UserId VARCHAR(255) REFERENCES users(Id) ON DELETE CASCADE,
    DoctorId VARCHAR(255) REFERENCES doctors(Id) ON DELETE CASCADE,
    ClinicId VARCHAR(255) REFERENCES clinics(Id) ON DELETE CASCADE,
    AdminId VARCHAR(255) REFERENCES admins(Id) ON DELETE CASCADE,
    NotificationType VARCHAR(50) NOT NULL CHECK (NotificationType IN ('AnalysisComplete', 'HighRiskAlert', 'PaymentSuccess', 'PackageExpiring', 'MessageReceived', 'SystemAlert', 'Other')),
    Title VARCHAR(255) NOT NULL,
    Description TEXT NOT NULL,
    RelatedEntityType VARCHAR(50),
    RelatedEntityId VARCHAR(255),
    IsRead BOOLEAN DEFAULT FALSE,
    ReadAt TIMESTAMP,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE,
    CHECK (
        (UserId IS NOT NULL AND DoctorId IS NULL AND ClinicId IS NULL AND AdminId IS NULL) OR
        (UserId IS NULL AND DoctorId IS NOT NULL AND ClinicId IS NULL AND AdminId IS NULL) OR
        (UserId IS NULL AND DoctorId IS NULL AND ClinicId IS NOT NULL AND AdminId IS NULL) OR
        (UserId IS NULL AND DoctorId IS NULL AND ClinicId IS NULL AND AdminId IS NOT NULL)
    )
);

-- =====================================================
-- SECTION 8: REPORTS & CONFIGURATIONS (Admin Features)
-- =====================================================

CREATE TABLE exported_reports (
    Id VARCHAR(255) PRIMARY KEY,
    ResultId VARCHAR(255) REFERENCES analysis_results(Id) ON DELETE SET NULL,
    ReportType VARCHAR(50) NOT NULL CHECK (ReportType IN ('PDF', 'CSV', 'JSON', 'Excel')),
    FilePath VARCHAR(500) NOT NULL,
    FileUrl VARCHAR(500),
    FileSize BIGINT,
    RequestedBy VARCHAR(255) NOT NULL,
    RequestedByType VARCHAR(20) NOT NULL CHECK (RequestedByType IN ('User', 'Doctor', 'Admin', 'Clinic')),
    ExportedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ExpiresAt TIMESTAMP,
    DownloadCount INTEGER DEFAULT 0,
    LastDownloadedAt TIMESTAMP,
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE clinic_reports (
    Id VARCHAR(255) PRIMARY KEY,
    ClinicId VARCHAR(255) NOT NULL REFERENCES clinics(Id) ON DELETE CASCADE,
    ReportName VARCHAR(255) NOT NULL,
    ReportType VARCHAR(50) NOT NULL CHECK (ReportType IN ('ScreeningCampaign', 'RiskDistribution', 'MonthlySummary', 'AnnualReport', 'Custom')),
    PeriodStart DATE,
    PeriodEnd DATE,
    TotalPatients INTEGER DEFAULT 0,
    TotalAnalyses INTEGER DEFAULT 0,
    HighRiskCount INTEGER DEFAULT 0,
    MediumRiskCount INTEGER DEFAULT 0,
    LowRiskCount INTEGER DEFAULT 0,
    ReportData JSONB,
    GeneratedBy VARCHAR(255) REFERENCES admins(Id),
    GeneratedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReportFileUrl VARCHAR(500),
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE ai_configurations (
    Id VARCHAR(255) PRIMARY KEY,
    ConfigurationName VARCHAR(255) NOT NULL UNIQUE,
    ConfigurationType VARCHAR(50) NOT NULL CHECK (ConfigurationType IN ('Threshold', 'Parameter', 'Policy', 'Retraining')),
    ModelVersionId VARCHAR(255) REFERENCES ai_model_versions(Id),
    ParameterKey VARCHAR(255) NOT NULL,
    ParameterValue TEXT NOT NULL,
    ParameterDataType VARCHAR(50) CHECK (ParameterDataType IN ('Number', 'String', 'Boolean', 'JSON')),
    Description TEXT,
    IsActive BOOLEAN DEFAULT TRUE,
    AppliedAt TIMESTAMP,
    AppliedBy VARCHAR(255) REFERENCES admins(Id),
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE notification_templates (
    Id VARCHAR(255) PRIMARY KEY,
    TemplateName VARCHAR(255) NOT NULL UNIQUE,
    TemplateType VARCHAR(50) NOT NULL CHECK (TemplateType IN ('AnalysisComplete', 'HighRiskAlert', 'PaymentSuccess', 'PackageExpiring', 'MessageReceived', 'SystemAlert', 'Custom')),
    TitleTemplate VARCHAR(500) NOT NULL,
    ContentTemplate TEXT NOT NULL,
    Variables JSONB,
    IsActive BOOLEAN DEFAULT TRUE,
    Language VARCHAR(10) DEFAULT 'vi' CHECK (Language IN ('vi', 'en')),
    CreatedDate DATE,
    CreatedBy VARCHAR(255),
    UpdatedDate DATE,
    UpdatedBy VARCHAR(255),
    IsDeleted BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- SECTION 9: AUDIT (System Logging)
-- =====================================================

CREATE TABLE audit_logs (
    Id VARCHAR(255) PRIMARY KEY,
    UserId VARCHAR(255) REFERENCES users(Id) ON DELETE SET NULL,
    DoctorId VARCHAR(255) REFERENCES doctors(Id) ON DELETE SET NULL,
    AdminId VARCHAR(255) REFERENCES admins(Id) ON DELETE SET NULL,
    ActionType VARCHAR(100) NOT NULL,
    ResourceType VARCHAR(100) NOT NULL,
    ResourceId VARCHAR(255),
    OldValues JSONB,
    NewValues JSONB,
    IpAddress VARCHAR(45),
    UserAgent TEXT,
    CreatedDate DATE,
    CreatedBy VARCHAR(255)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Core entities - Email indexes
CREATE INDEX idx_users_email ON users(Email);
CREATE INDEX idx_doctors_email ON doctors(Email);
CREATE INDEX idx_clinics_email ON clinics(Email);
CREATE INDEX idx_admins_email ON admins(Email);

-- Relationship tables - Foreign keys
CREATE INDEX idx_user_roles_user_id ON user_roles(UserId);
CREATE INDEX idx_user_roles_role_id ON user_roles(RoleId);
CREATE INDEX idx_clinic_doctors_clinic_id ON clinic_doctors(ClinicId);
CREATE INDEX idx_clinic_doctors_doctor_id ON clinic_doctors(DoctorId);
CREATE INDEX idx_clinic_users_clinic_id ON clinic_users(ClinicId);
CREATE INDEX idx_clinic_users_user_id ON clinic_users(UserId);

-- Images & Analysis - Foreign keys
CREATE INDEX idx_retinal_images_user_id ON retinal_images(UserId);
CREATE INDEX idx_retinal_images_clinic_id ON retinal_images(ClinicId);
CREATE INDEX idx_retinal_images_batch_id ON retinal_images(BatchId);
CREATE INDEX idx_analysis_results_image_id ON analysis_results(ImageId);
CREATE INDEX idx_analysis_results_user_id ON analysis_results(UserId);
CREATE INDEX idx_analysis_results_model_version_id ON analysis_results(ModelVersionId);
CREATE INDEX idx_annotations_result_id ON annotations(ResultId);
CREATE INDEX idx_medical_notes_result_id ON medical_notes(ResultId);
CREATE INDEX idx_medical_notes_doctor_id ON medical_notes(DoctorId);
CREATE INDEX idx_ai_feedback_result_id ON ai_feedback(ResultId);
CREATE INDEX idx_ai_feedback_doctor_id ON ai_feedback(DoctorId);

-- Packages & Payments - Foreign keys
CREATE INDEX idx_user_packages_user_id ON user_packages(UserId);
CREATE INDEX idx_user_packages_clinic_id ON user_packages(ClinicId);
CREATE INDEX idx_user_packages_package_id ON user_packages(PackageId);
CREATE INDEX idx_payment_history_user_id ON payment_history(UserId);
CREATE INDEX idx_payment_history_clinic_id ON payment_history(ClinicId);
CREATE INDEX idx_payment_history_package_id ON payment_history(PackageId);

-- Communication - Foreign keys
CREATE INDEX idx_notifications_user_id ON notifications(UserId);
CREATE INDEX idx_notifications_doctor_id ON notifications(DoctorId);
CREATE INDEX idx_notifications_clinic_id ON notifications(ClinicId);
CREATE INDEX idx_messages_conversation_id ON messages(ConversationId);

-- Status columns - Frequently filtered
CREATE INDEX idx_retinal_images_upload_status ON retinal_images(UploadStatus);
CREATE INDEX idx_analysis_results_status ON analysis_results(AnalysisStatus);
CREATE INDEX idx_analysis_results_risk_level ON analysis_results(OverallRiskLevel);
CREATE INDEX idx_payment_history_status ON payment_history(PaymentStatus);
CREATE INDEX idx_clinics_verification_status ON clinics(VerificationStatus);
CREATE INDEX idx_clinic_reports_report_type ON clinic_reports(ReportType);
CREATE INDEX idx_notifications_is_read ON notifications(IsRead);
CREATE INDEX idx_messages_is_read ON messages(IsRead);

-- Date columns - Range queries
CREATE INDEX idx_retinal_images_uploaded_at ON retinal_images(UploadedAt);
CREATE INDEX idx_payment_history_date ON payment_history(PaymentDate);
CREATE INDEX idx_user_packages_expires_at ON user_packages(ExpiresAt);
CREATE INDEX idx_clinic_reports_period ON clinic_reports(PeriodStart, PeriodEnd);
CREATE INDEX idx_audit_logs_created_date ON audit_logs(CreatedDate);
CREATE INDEX idx_exported_reports_exported_at ON exported_reports(ExportedAt);

-- =====================================================
-- TABLE COMMENTS
-- =====================================================

-- Section 1: Roles and Permissions
COMMENT ON TABLE roles IS 'System roles';
COMMENT ON TABLE permissions IS 'System permissions';
COMMENT ON TABLE role_permissions IS 'Role-permission mapping';

-- Section 2: Core Entities
COMMENT ON TABLE users IS 'Patient/user accounts';
COMMENT ON TABLE doctors IS 'Doctor accounts';
COMMENT ON TABLE clinics IS 'Clinic/organization information';
COMMENT ON TABLE admins IS 'System administrator accounts';

-- Section 3: Relationships
COMMENT ON TABLE user_roles IS 'User-role mapping';
COMMENT ON TABLE clinic_doctors IS 'Clinic-doctor relationships';
COMMENT ON TABLE clinic_users IS 'Clinic-user relationships';
COMMENT ON TABLE patient_doctor_assignments IS 'Patient-doctor assignments';

-- Section 4: AI Models
COMMENT ON TABLE ai_model_versions IS 'AI model versions';

-- Section 5: Images & Analysis
COMMENT ON TABLE retinal_images IS 'Retinal fundus/OCT images';
COMMENT ON TABLE bulk_upload_batches IS 'Bulk upload batches';
COMMENT ON TABLE analysis_results IS 'AI analysis results and risk assessments';
COMMENT ON TABLE annotations IS 'Image annotations';
COMMENT ON TABLE ai_feedback IS 'Doctor feedback on AI results';
COMMENT ON TABLE medical_notes IS 'Medical notes and diagnoses';

-- Section 6: Packages & Payments
COMMENT ON TABLE service_packages IS 'Service packages';
COMMENT ON TABLE user_packages IS 'Purchased packages';
COMMENT ON TABLE payment_history IS 'Payment transactions';

-- Section 7: Communication
COMMENT ON TABLE messages IS 'Consultation messages';
COMMENT ON TABLE notifications IS 'System notifications';

-- Section 8: Reports & Configurations
COMMENT ON TABLE exported_reports IS 'Exported reports';
COMMENT ON TABLE clinic_reports IS 'Clinic-wide reports';
COMMENT ON TABLE ai_configurations IS 'AI configurations';
COMMENT ON TABLE notification_templates IS 'Notification templates';

-- Section 9: Audit
COMMENT ON TABLE audit_logs IS 'Audit trail';

-- =====================================================
-- END OF SCHEMA
-- =====================================================
