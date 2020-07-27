USE [DatabaseName]
GO

-- Set ansi nulls
SET ANSI_NULLS ON
GO

-- Set quoted identifier
SET QUOTED_IDENTIFIER ON
GO

-- =============================
--        File: GeneratedSerial
--     Created: 07/26/2020
--     Updated: 07/26/2020
--  Programmer: Cuates
--   Update By: Cuates
--     Purpose: Generated serial
-- =============================
CREATE TABLE [dbo].[GeneratedSerial](
  [gsID] [int] identity (1, 1) not null,
  [created_date] [datetime2](7) not null,
  [modified_date] [datetime2](7) null,
  [generated_serial] [nvarchar](70) not null,
  [searchable_serial] [nvarchar](70) null,
  [serial_family] [nvarchar](255) null,
  CONSTRAINT [UK_GeneratedSerial_generated_serial_family] UNIQUE NONCLUSTERED
  (
    [generated_serial],
    [serial_family]
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GeneratedSerial] ADD  DEFAULT ((0)) FOR [consumed]
GO

ALTER TABLE [dbo].[GeneratedSerial] ADD  DEFAULT (getdate()) FOR [created_date]
GO

ALTER TABLE [dbo].[GeneratedSerial] ADD  DEFAULT (getdate()) FOR [modified_date]
GO