# Inquiry System ERD

## Logical ERD

```mermaid
erDiagram
    DEPARTMENTS ||--o{ USERS : has
    DEPARTMENTS ||--o{ INQUIRIES : receives
    USERS ||--o{ INQUIRIES : submits
    USERS ||--o{ INQUIRIES : assigned_to
    INQUIRIES ||--o{ MESSAGES : contains
    USERS ||--o{ MESSAGES : writes
    INQUIRIES ||--o{ NOTIFICATIONS : triggers
    USERS ||--o{ NOTIFICATIONS : receives
    USERS ||--o{ PERSONAL_ACCESS_TOKENS : owns
```

## Physical ERD

```mermaid
erDiagram
    departments {
        bigint id PK
        varchar name UK
        varchar slug UK
        varchar email UK
        text description
        varchar phone
        varchar office_hours
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    users {
        bigint id PK
        varchar user_identifier UK
        varchar name
        varchar email UK
        varchar password
        varchar user_type
        bigint department_id FK
        varchar profile_photo_path
        varchar phone
        varchar address
        text bio
        timestamp created_at
        timestamp updated_at
    }

    inquiries {
        bigint id PK
        bigint student_id FK
        bigint department_id FK
        varchar category
        bigint assigned_admin_id FK
        varchar subject
        text description
        enum status
        integer priority
        text resolution_notes
        timestamp resolved_at
        timestamp closed_at
        timestamp created_at
        timestamp updated_at
    }

    messages {
        bigint id PK
        bigint inquiry_id FK
        bigint user_id FK
        text message
        varchar attachment_path
        timestamp read_at
        timestamp created_at
        timestamp updated_at
    }

    notifications {
        bigint id PK
        bigint user_id FK
        bigint inquiry_id FK
        varchar title
        text message
        varchar type
        timestamp read_at
        timestamp created_at
        timestamp updated_at
    }

    personal_access_tokens {
        bigint id PK
        varchar tokenable_type
        bigint tokenable_id
        varchar name
        varchar token UK
        text abilities
        timestamp last_used_at
        timestamp expires_at
        timestamp created_at
        timestamp updated_at
    }

    departments ||--o{ users : department_id
    departments ||--o{ inquiries : department_id
    users ||--o{ inquiries : student_id
    users ||--o{ inquiries : assigned_admin_id
    inquiries ||--o{ messages : inquiry_id
    users ||--o{ messages : user_id
    inquiries ||--o{ notifications : inquiry_id
    users ||--o{ notifications : user_id
    users ||--o{ personal_access_tokens : tokenable
```

## API Coverage

- `POST /api/login`, `POST /api/register`, `POST /api/logout`, `GET /api/me`
- `GET /api/dashboard`
- `GET /api/departments`
- `GET /api/inquiries`
- `POST /api/inquiries`
- `GET /api/inquiries/{inquiry}`
- `PUT /api/inquiries/{inquiry}`
- `DELETE /api/inquiries/{inquiry}`
- `PUT /api/profile`
