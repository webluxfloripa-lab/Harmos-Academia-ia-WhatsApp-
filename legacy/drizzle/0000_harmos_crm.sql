CREATE TABLE crm_leads (id TEXT PRIMARY KEY, client_id TEXT NOT NULL UNIQUE, topic TEXT NOT NULL, kind TEXT NOT NULL CHECK(kind IN ('aluno','interessado')), name TEXT NOT NULL DEFAULT '', phone TEXT NOT NULL DEFAULT '', goal TEXT NOT NULL DEFAULT '', preference TEXT NOT NULL DEFAULT '', source TEXT NOT NULL DEFAULT '', summary TEXT NOT NULL, handoff_hash TEXT NOT NULL, handoff_draft TEXT NOT NULL DEFAULT '', stage TEXT NOT NULL DEFAULT 'Novo', owner TEXT NOT NULL DEFAULT '', next_due TEXT NOT NULL DEFAULT '', notes TEXT NOT NULL DEFAULT '', opened_at TEXT, consent_version TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
--> statement-breakpoint
CREATE INDEX crm_leads_created ON crm_leads(created_at);
--> statement-breakpoint
CREATE TABLE crm_events (id TEXT PRIMARY KEY, lead_id TEXT, actor TEXT NOT NULL, event TEXT NOT NULL, detail TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL);
--> statement-breakpoint
CREATE INDEX crm_events_lead ON crm_events(lead_id);
--> statement-breakpoint
CREATE TABLE crm_knowledge (id TEXT PRIMARY KEY, body TEXT NOT NULL, revision INTEGER NOT NULL DEFAULT 1, updated_at TEXT NOT NULL);
--> statement-breakpoint
CREATE TABLE crm_limits (key TEXT PRIMARY KEY, hits INTEGER NOT NULL, expires INTEGER NOT NULL);
--> statement-breakpoint
