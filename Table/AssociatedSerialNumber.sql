use [DatabaseName]
go

-- Set ansi nulls
set ansi_nulls on
go

-- Set quoted identifier
set quoted_identifier on
go

-- =====================================
--        File: AssociatedSerialNumber
--     Created: 07/26/2020
--     Updated: 07/29/2020
--  Programmer: Cuates
--   Update By: Cuates
--     Purpose: Associated serial number
-- =====================================
create table [dbo].[AssociatedSerialNumber](
  [asnID] [bigint] identity (1, 1) not null,
  [temp_serial] [nvarchar](70) null,
  [main_serial] [nvarchar](70) null,
  [created_date] [datetime2](7) null,
  [modified_date] [datetime2](7) null,
  constraint [UK_AssociatedSerialNumber_main_serial] unique nonclustered
  (
    [main_serial] asc
  )with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [primary],
  constraint [UK_AssociatedSerialNumber_temp_serial] unique nonclustered
  (
    [temp_serial] asc
  )with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [primary]
) on [primary]
go

alter table [dbo].[AssociatedSerialNumber] add  default (getdate()) for [created_date]
go

alter table [dbo].[AssociatedSerialNumber] add  default (getdate()) for [modified_date]
go