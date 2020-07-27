USE [DatabaseName]
GO

-- Set ansi nulls
SET ANSI_NULLS ON
GO

-- Set quoted identifier
SET QUOTED_IDENTIFIER ON
GO

-- =====================================
--        File: AssociatedSerialNumber
--     Created: 07/26/2020
--     Updated: 07/26/2020
--  Programmer: Cuates
--   Update By: Cuates
--     Purpose: Associated serial number
-- =====================================
CREATE TABLE [dbo].[AssociatedSerialNumber](
  [asnID] [int] identity (1, 1) not null,
  [temp_serial] [nvarchar](70) null,
  [main_serial] [nvarchar](70) null,
  [created_date] [datetime2](7) null,
  [modified_date] [datetime2](7) null,
  CONSTRAINT [UK_AssociatedSerialNumber_main_serial] UNIQUE NONCLUSTERED
  (
    [main_serial] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
  CONSTRAINT [UK_AssociatedSerialNumber_temp_serial] UNIQUE NONCLUSTERED
  (
    [temp_serial] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AssociatedSerialNumber] ADD  DEFAULT (getdate()) FOR [created_date]
GO

ALTER TABLE [dbo].[AssociatedSerialNumber] ADD  DEFAULT (getdate()) FOR [modified_date]
GO