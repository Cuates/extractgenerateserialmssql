# extractgenerateserialmssql
> Microsoft SQL Server project which utilizes a stored procedure to extract and generate serial(s)

## Table of Contents
* [Version](#version)
* [Important Note](#important-note)
* [Dependent MSSQL Function](#dependent-mssql-function)
* [Prerequisite Data Types](#prerequisite-data-types)
* [Prerequisite Functions](#prerequisite-functions)
* [Prerequisite Conditions](#prerequisite-conditions)
* [Usage](#usage)

### Version
* 0.0.1

### **Important Note**
* This project was written with SQL Server 2012 methods

### Dependent MSSQL Function
* [Omit Characters](https://github.com/Cuates/omitcharactersmssql)

### Prerequisite Data Types
* int
* smallint
* nvarchar
* datetime2

### Prerequisite Functions
* nullif
* ltrim
* rtrim
* getdate
* getdate
* format
* count
* substring
* len
* floor
* reverse
* charindex
* error_number
* error_line
* error_message

### Prerequisite Conditions
* exists

### Usage
* `dbo.extractGenerateSerial @optionMode = 'extractSerial', @searchable_serial = 'SearchableSerial'`
* `dbo.extractGenerateSerial @optionMode = 'generateSerial', @searchable_serial = 'SearchableSerial'`
