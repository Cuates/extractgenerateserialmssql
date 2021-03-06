use [DatabaseName]
go

-- Set ansi nulls
set ansi_nulls on
go

-- Set quoted identifier
set quoted_identifier on
go

-- ====================================
--        File: extractGenerateSerial
--     Created: 07/25/2020
--     Updated: 08/26/2020
--  Programmer: Cuates
--   Update By: Cuates
--     Purpose: Extract generate serial
-- ====================================
create procedure [dbo].[extractGenerateSerial]
  -- Parameters
  @optionMode nvarchar(255),
  @searchableSerial nvarchar(255) = null
as
begin
  -- Set nocount on added to prevent extra result sets from interfering with select statements
  set nocount on

  -- Declare variables
  declare @attempts as smallint
  declare @currPos nvarchar(255) -- Current position
  declare @serialGenerationQuantity int -- Serial generation quantity
  declare @serialFamily nvarchar(255) -- Serial family
  declare @currDate datetime2(7) -- Get current date
  declare @twoDigitYear nvarchar(255) -- Get current year
  declare @twoDigitMonth nvarchar(255) -- Get current month
  declare @twoDigitDay nvarchar(255) -- Get current day
  declare @stringPartOne nvarchar(255) -- String part one
  declare @stringPartTwo nvarchar(255) -- String part two
  declare @stringPartThree nvarchar(255) -- String part three
  declare @generatedSerial nvarchar(255) -- Initial Entry for first serial number
  declare @possCharCount int -- Get possible character count
  declare @prevSubstring varchar(max) -- Get previous substring
  declare @buildSerial nvarchar(max) -- Get build serial
  declare @serialQuantity int -- Get serial quantity
  declare @lenBuildSerial int -- Get length of build serial
  declare @stringStringLimit nvarchar(max) -- Get string serial limit
  declare @prevPos int -- Get previous position
  declare @buildSerialReverse nvarchar(max) -- Get build serial in reverse
  declare @lenDecrementedString int -- Get length of decremented string
  declare @currCharacterPossPos int -- Get current character possible position
  declare @calCharacterPossPos int -- Get calculated character possible position
  declare @modCharacterPossPos int -- Get modulo of character possible position
  declare @badWordCount int -- Get bad word count
  declare @currBadWordPos int -- Get current bad word position
  declare @badWordComparisonValue int -- Get bad word comparison value
  declare @badWordComparisonString nvarchar(max) -- Get bad word comparison string
  declare @completedSerialString nvarchar(max) -- Get completed serial string

  -- Set variables
  set @attempts = 1

  -- Declare a bad word temporary table
  declare @badWordTemp table
  (
    bwtID int identity (1, 1) primary key,
    badWord nvarchar(max) null
  )

  -- Declare a possible character temporary table
  declare @possibleCharacterTemp table
  (
    pctID int identity (1, 1) primary key,
    possbileCharacter nvarchar(255) null
  )

  -- Omit characters
  set @optionMode = dbo.OmitCharacters(@optionMode, '48,59,50,51,52,53,54,55,56,57,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122')

  -- Check if empty string
  if @optionMode = ''
    begin
      -- Set parameter to null if empty string
      set @optionMode = nullif(@optionMode, '')
    end

  -- Omit characters
  set @searchable_serial = dbo.OmitCharacters(@searchable_serial, '48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122')

  -- Check if empty string
  if @searchable_serial = ''
    begin
      -- Set parameter to null if empty string
      set @searchable_serial = nullif(@searchable_serial, '')
    end

  -- Check if option mode is extract serial
  if @optionMode = 'extractSerial'
    begin
      -- Select record
      select
      gs.generated_serial as [Generated Serial],
      gs.searchable_serial as [Searchable Serial],
      'Success~Extracted serial' as [Status]
      from dbo.GeneratedSerial gs
      where
      gs.searchable_serial = @searchable_serial
      order by gs.generated_serial desc
    end

  -- Else check if option mode is generate serial
  else if @optionMode = 'generateSerial'
    begin
      -- Set variables
      set @currPos = 0
      set @serialGenerationQuantity = 1
      set @serialFamily = 'SerialFamily'
      set @currDate = getdate()
      set @twoDigitYear = format(@currDate, 'yy', 'en-us')
      set @twoDigitMonth = format(@currDate, 'MM', 'en-us')
      set @twoDigitDay = format(@currDate, 'dd', 'en-us')
      set @stringPartOne = '012'
      set @stringPartTwo = '345'
      set @stringPartThree = '012A'
      set @stringStringLimit = 'ZZZ'
      set @calCharacterPossPos = 0

      -- Check if record exists
      if exists
      (
        -- Select record
        select
        mtn.main_serial as [main_serial]
        from dbo.MainTableName mtn
        where
        mtn.main_serial = @searchableSerial
        group by mtn.main_serial
      )
        begin
          -- Loop until condition is met
          while @attempts <= 5
            begin
              -- Begin the tranaction
              begin tran
                -- Begin the try block
                begin try
                  -- Loop until condition is met
                  while @currPos < @serialGenerationQuantity
                    begin
                      -- Check if there are no existing records for the serial family
                      if ((select count(*) as [serialCount] from dbo.GeneratedSerial gs where gs.serial_family = @serialFamily) <= 0)
                        begin
                          -- Set variable with generated serial
                          set @generatedSerial = @twoDigitYear + @twoDigitMonth + @twoDigitDay + @stringPartOne + @stringPartTwo + @stringPartThree

                          -- Check if record does not exist based on searchable serial and generated serial
                          if not exists
                          (
                            -- Select record
                            select
                            top 1
                            asn.asID as [asID]
                            from dbo.AssociatedSerialNumber asn
                            where
                            asn.temp_serial = @searchableSerial or
                            asn.main_serial = @generatedSerial
                          )
                            begin
                              -- Insert first generated serial manually to start it off
                              -- The first generated serial will not be used unless the end user requests it
                              insert into dbo.GeneratedSerial (generated_serial, searchable_serial, serial_family) values (@generatedSerial, @searchableSerial, @serialFamily)

                              -- Insert current serial number into another table
                              insert into dbo.AssociatedSerialNumber (temp_serial, main_serial) values (@searchableSerial, @generatedSerial)

                              -- Update main table name
                              update dbo.MainTableName
                              set
                              main_serial = @generatedSerial,
                              modified_date = getdate()
                              where
                              main_serial = @searchableSerial
                            end

                          -- Increment position
                          set @currPos = @currPos + 1
                        end

                      -- Else check if record does not exist based on a substring of the generated serial and serial family
                      else if not exists
                      (
                        -- Select record
                        select
                        top 1
                        gs.generated_serial as [generated_serial]
                        from dbo.GeneratedSerial gs
                        where
                        substring(gs.generated_serial, 1, 6) = @twoDigitYear + @twoDigitMonth + @twoDigitDay and
                        gs.serial_family = @serialFamily
                        order by gs.gsID desc
                      )
                        begin
                          -- Set variable with generated serial
                          set @generatedSerial = @twoDigitYear + @twoDigitMonth + @twoDigitDay + @stringPartOne + @stringPartTwo + @stringPartThree

                          -- Check if record does not exist based on searchable serial and generated serial
                          if not exists
                          (
                            -- Select record
                            select
                            top 1
                            asn.asnID as [asnID]
                            from dbo.AssociatedSerialNumber asn
                            where
                            asn.temp_serial = @searchableSerial or
                            asn.main_serial = @generatedSerial
                          )
                            begin
                              -- Insert first generated serial manually to start it off
                              -- The first generated serial will not be used unless the end user requests it
                              insert into dbo.GeneratedSerial (generated_serial, searchable_serial, serial_family) values (@generatedSerial, @searchableSerial, @serialFamily)

                              -- Insert searchable serial and generated serial into the table
                              insert into dbo.AssociatedSerialNumber (temp_serial, main_serial) values (@searchableSerial, @generatedSerial)

                              -- Update main table name
                              update dbo.MainTableName
                              set
                              main_serial = @generatedSerial,
                              modified_date = getdate()
                              where
                              main_serial = @searchableSerial
                            end

                          -- Increment current position
                          set @currPos = @currPos + 1
                        end

                      -- Else generate serial
                      else
                        begin
                          -- Insert possible character string values into temporary table
                          insert into @possibleCharacterTemp (possbileCharacter) values ('0'), ('1'), ('2'), ('3'), ('4'), ('5'), ('6'), ('7'), ('8'), ('9'), ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J'), ('K'), ('L'), ('M'), ('N'), ('O'), ('P'), ('Q'), ('R'), ('S'), ('T'), ('U'), ('V'), ('W'), ('X'), ('Y'), ('Z')

                          -- Set variable with possible character count based on possible character temporary table
                          set @possCharCount =
                          (
                            -- Select record
                            select
                            count(*)
                            from @possibleCharacterTemp
                          )

                          -- Set variable with serial quantity
                          set @serialQuantity = @currPos

                          -- Set variable with a substring of the previous generated serial
                          set @prevSubstring =
                          (
                            -- Select record
                            select
                            top 1
                            substring(gs.generated_serial, 10, 3)
                            from dbo.GeneratedSerial gs
                            where
                            gs.serial_family = @serialFamily
                            order by gs.gsID desc
                          )

                          -- Set variable with the substring of the previous generated serial
                          set @buildSerial = @prevSubstring

                          -- Loop until condition is met for n amount of generated serials
                          while @serialQuantity < @serialGenerationQuantity
                            begin
                              -- Check if record does not exists based on build serial
                              if not exists
                              (
                                -- Select record
                                select
                                badWord
                                from @badWordTemp
                                where
                                badWord = @buildSerial
                              )
                                begin
                                  -- Set variable with a substring of the previous generated serial
                                  set @prevSubstring =
                                  (
                                    -- Select record
                                    select
                                    top 1
                                    substring(gs.generated_serial, 10, 3)
                                    from dbo.GeneratedSerial gs
                                    where
                                    gs.serial_family = @serialFamily
                                    order by gs.gsID desc
                                  )

                                  -- Set variable with a substring of the previous generated serial
                                  set @buildSerial = @prevSubstring
                                end

                              -- Set variable with length value of the build serial
                              set @lenBuildSerial =
                              (
                                -- Select record
                                select
                                len(@buildSerial)
                              )

                              -- Check if build string and string serial limit match
                              if @buildSerial = @stringStringLimit
                                begin
                                  -- Select record
                                  select
                                  '' as [Generated Serial],
                                  '' as [Searchable Serial],
                                  'Error~Exceeded Serial Number Limit' as [Status]

                                  -- Break out of stored procedure
                                  return
                                end

                              -- Set variables
                              set @prevPos = 1
                              set @buildSerialReverse = ''

                              -- Set variable with length of the build serial
                              set @lenDecrementedString = @lenBuildSerial

                              -- Loop until condition is met based on the decrementing string length
                              while @lenDecrementedString > 0
                                begin
                                  -- Set variable
                                  set @currCharacterPossPos = 0

                                  -- Set variable with a character string based on a substring of build serial and length of the decrementing string
                                  set @currCharacterPossPos =
                                  (
                                    -- Select record
                                    select
                                    pctID
                                    from @possibleCharacterTemp
                                    where
                                    possbileCharacter = substring(@buildSerial, @lenDecrementedString, 1)
                                  )

                                  -- Check if the varaible is set and not an empty string
                                  if @currCharacterPossPos is null or @currCharacterPossPos = ''
                                    begin
                                      -- Set variable
                                      set @currCharacterPossPos = 0
                                    end

                                  -- Set variable with calculated current character possible position added with the previous position
                                  set @calCharacterPossPos = @currCharacterPossPos + @prevPos

                                  -- Set variable with the modulo value based on calculated character possible position and possible character count
                                  set @modCharacterPossPos = @calCharacterPossPos % @possCharCount

                                  -- Set variable with the string character starting from the right most character based on the modulo value
                                  set @buildSerialReverse = @buildSerialReverse +
                                  (
                                    -- Select record
                                    select
                                    possbileCharacter
                                    from @possibleCharacterTemp
                                    where
                                    pctID = @modCharacterPossPos
                                  )

                                  -- Check if variable values are equal to each other
                                  if @calCharacterPossPos = @possCharCount
                                    begin
                                      -- Set variable with the floor of possible character count divided by calculated character possible position
                                      set @prevPos = floor(@possCharCount/@calCharacterPossPos)
                                    end
                                  else
                                    begin
                                      -- Else set variable with the floor of calculcated character possible position divided by possible character count
                                      set @prevPos = floor(@calCharacterPossPos/@possCharCount)
                                    end

                                  -- Decrement the length of the string
                                  set @lenDecrementedString = @lenDecrementedString - 1
                                end

                              -- Set variable by reversing the string of build serial reverse
                              set @buildSerial = reverse(@buildSerialReverse)

                              -- Set variables
                              set @badWordCount =
                              (
                                -- Select record
                                select
                                count(*)
                                from @badWordTemp
                              )
                              set @currBadWordPos = 0
                              set @badWordComparisonValue = 0

                              -- Loop until condition is met based on all possible bad words in the temporary table
                              while @currBadWordPos <= @badWordCount
                                begin
                                  -- Set variable with one bad word in the temporary table
                                  set @badWordComparisonString =
                                  (
                                    -- Select record
                                    select
                                    badWord
                                    from @badWordTemp
                                    where
                                    bwtID = @currBadWordPos
                                  )

                                  -- Set variable with the matched position of the compared build serial
                                  set @badWordComparisonValue =
                                  (
                                    -- Select
                                    select
                                    charindex(@badWordComparisonString, @buildSerial)
                                  )

                                  --  If value is null
                                  if @badWordComparisonValue is null
                                    begin
                                      -- Set variable with zero as bad word was not found
                                      set @badWordComparisonValue = 0
                                    end

                                  -- Check if bad word was found
                                  if @badWordComparisonValue > 0
                                    begin
                                      -- Break from while loop as there was a bad word found
                                      break
                                    end

                                  -- Increment position
                                  set @currBadWordPos = @currBadWordPos + 1
                                end

                              -- Check if bad word was not found
                              if @badWordComparisonValue <= 0
                                begin
                                  -- Increment serial quantity
                                  set @serialQuantity = @serialQuantity + 1

                                  -- Increment current position
                                  set @currPos = @currPos + 1

                                  -- Set variable with the build serial
                                  set @completedSerialString = @buildSerial

                                  -- Set variable
                                  set @generatedSerial = ''

                                  -- Set variable with all sub string parts
                                  set @generatedSerial = @twoDigitYear + @twoDigitMonth + @twoDigitDay + @stringPartOne + @completedSerialString + @stringPartThree

                                  -- Check if record does not exist based on searchable serial and generated serial
                                  if not exists
                                  (
                                    -- Select record
                                    select
                                    top 1
                                    asn.ID as [asnID]
                                    from dbo.AssociatedSerialNumber asn
                                    where
                                    asn.temp_serial = @searchableSerial or
                                    asn.main_serial = @generatedSerial
                                  )
                                    begin
                                      -- Insert record into generated serial table
                                      insert into dbo.generated_serial (catpsnvalue, searchable_serial, serial_family) values (@generatedSerial, @searchableSerial, @serialFamily)

                                      -- Insert record into associated serial number table
                                      insert into dbo.AssociatedSerialNumber (temp_serial, main_serial) values (@searchableSerial, @generatedSerial)

                                      -- Update main table name
                                      update dbo.MainTableName
                                      set
                                      main_serial = @generatedSerial,
                                      edit_date = getdate()
                                      where
                                      main_serial = @searchableSerial
                                    end
                                end
                              -- Else do nothing as the generated serial was bad
                            end
                        end
                    end

                  -- Select record
                  select
                  gs.generated_serial as [Generated Serial],
                  gs.searchable_serial as [Searchable Serial],
                  'Success~Generated serial' as [Status]
                  from dbo.GeneratedSerial gs
                  where
                  gs.searchable_serial = @searchableSerial
                  order by gs.gsID desc

                  -- Check if there is trans count
                  if @@trancount > 0
                    begin
                      -- Commit transactional statement
                      commit tran
                    end

                  -- Break out of the loop
                  break
                end try
                -- End try block
                -- Begin catch block
                begin catch
                  -- Only display an error message if it is on the final attempt of the execution
                  if @attempts = 5
                    begin
                      -- Select error number, line, and message
                      select
                      '' as [Generated Serial],
                      '' as [Searchable Serial],
                      'Error~generateSerial: Error Number: ' + cast(error_number() as nvarchar) + ' Error Line: ' + cast(error_line() as nvarchar) + ' Error Message: ' + error_message() as [Status]
                    end

                  -- Check if there is trans count
                  if @@trancount > 0
                    begin
                      -- Rollback to the previous state before the transaction was called
                      rollback
                    end

                  -- Increments the loop control for attempts
                  set @attempts = @attempts + 1

                  -- Wait for delay for x amount of time
                  waitfor delay '00:00:04'

                  -- Continue the loop
                  continue
                end catch
                -- End catch block
            end
        end

      -- Else main serial was not found
      else
        begin
          -- Select record
          select
          '' as [Generated Serial],
          @searchableSerial as [Searchable Serial],
          'Error~Main serial was not found' as [Status]
          from dbo.GeneratedSerial gs
          where
          gs.searchable_serial = @searchableSerial
          order by gs.gsID desc
        end
    end

  -- Else option mode not found
  else
    begin
      -- Select message
      select
      '' as [Generated Serial],
      '' as [Searchable Serial],
      'Error~Option mode does not exist' as [Status]
    end
end