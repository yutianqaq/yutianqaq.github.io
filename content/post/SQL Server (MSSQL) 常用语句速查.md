---
title: SQL Server (MSSQL) 常用语句速查
date: 2026-08-16
draft: false
tags:
hidden: false
comments: false
---

# SQL Server (MSSQL) 常用语句速查

> 适用于 SQL Server 2012 及以上版本，以 SSMS / sqlcmd 为主要使用环境。

## 目录

1. [数据库操作](#一数据库操作)
2. [表操作](#二表操作)
3. [查看表结构](#三查看表结构)
4. [增删改查 (CRUD)](#四增删改查-crud)
5. [更新某值](#五更新某值)
6. [查询技巧](#六查询技巧)
7. [索引与约束](#七索引与约束)
8. [常用系统查询](#八常用系统查询)
9. [备份与还原](#九备份与还原)
- [注意事项](#十注意事项)

---

## 一、数据库操作

### 列出所有数据库

```sql
-- 方法一
SELECT name FROM sys.databases ORDER BY name;

-- 方法二
EXEC sp_helpdb;

-- 方法三
SELECT DATABASEPROPERTYEX('master', 'Status');  -- 查看某个库状态
```

### 查看当前数据库名称

```sql
SELECT DB_NAME() AS 当前数据库;
SELECT @@SERVERNAME AS 服务器名, @@VERSION AS 版本;
```

### 创建 / 删除 / 切换数据库

```sql
CREATE DATABASE TestDB
ON PRIMARY (
    NAME = 'TestDB_data',
    FILENAME = 'D:\Data\TestDB.mdf',
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 10MB
)
LOG ON (
    NAME = 'TestDB_log',
    FILENAME = 'D:\Data\TestDB.ldf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10%
);

-- 切换数据库
USE TestDB;

-- 删除数据库（谨慎！）
DROP DATABASE TestDB;
```

### 查看 / 收缩数据库

```sql
-- 查看库文件及大小（MB）
SELECT
    f.name AS 逻辑名,
    f.type_desc AS 类型,
    CAST(f.size / 128.0 AS DECIMAL(10, 2)) AS 大小MB,
    f.physical_name AS 物理路径
FROM sys.master_files f
WHERE f.database_id = DB_ID();

-- 收缩数据库 / 日志
DBCC SHRINKDATABASE (TestDB, 10);   -- 保留 10% 空闲空间
DBCC SHRINKFILE (TestDB_log, 100);  -- 日志收缩到 100MB
```

---

## 二、表操作

### 列出当前库的所有表

```sql
-- 方法一：推荐
SELECT *
FROM sys.tables
ORDER BY name;

-- 方法二
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- 方法三：含每个表的行数
SELECT
    t.name AS 表名,
    p.rows AS 行数,
    CAST(SUM(a.total_pages) * 8 / 1024.0 AS DECIMAL(10, 2)) AS 总大小MB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id AND i.index_id IN (0, 1)
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
GROUP BY t.name, p.rows
ORDER BY 总大小MB DESC;
```

### 列出指定库（非当前库）的表

```sql
-- 方法一：三段式名称，跨库查询（推荐，无需切换）
SELECT * FROM OtherDB.sys.tables ORDER BY name;

-- 方法二：信息架构视图同样支持跨库
SELECT TABLE_SCHEMA, TABLE_NAME
FROM OtherDB.INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

-- 方法三：临时切换过去再查
USE OtherDB;
SELECT * FROM sys.tables;

-- 方法四：不切换，指定库执行系统存储过程
EXEC OtherDB.sys.sp_tables @table_name = '%', @table_owner = 'dbo';
```

### 列出所有视图

```sql
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS;
```

### 创建表

```sql
CREATE TABLE dbo.Employee (
    ID        INT IDENTITY(1, 1) PRIMARY KEY,
    Name      NVARCHAR(50) NOT NULL,
    Age       INT CHECK (Age BETWEEN 0 AND 150),
    Salary    DECIMAL(12, 2) DEFAULT 0,
    DeptID    INT REFERENCES dbo.Department(ID),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME()
);
```

### 修改 / 删除 / 清空表

```sql
-- 加列
ALTER TABLE dbo.Employee ADD Email NVARCHAR(100);

-- 改列类型
ALTER TABLE dbo.Employee ALTER COLUMN Email NVARCHAR(200);

-- 删列
ALTER TABLE dbo.Employee DROP COLUMN Email;

-- 重命名表 / 列（旧语法，也可用新版 RENAME）
EXEC sp_rename 'OldTableName', 'NewTableName';
EXEC sp_rename 'dbo.Employee.Name', 'UserName', 'COLUMN';

-- 删除表（连数据带结构）
DROP TABLE dbo.Employee;

-- 清空表数据（快，重置自增，不能加 WHERE）
TRUNCATE TABLE dbo.Employee;
```

---

## 三、查看表结构

### 查看列信息

```sql
-- 方法一：信息架构视图
SELECT
    COLUMN_NAME     AS 列名,
    DATA_TYPE       AS 数据类型,
    IS_NULLABLE     AS 允许空,
    CHARACTER_MAXIMUM_LENGTH AS 长度,
    COLUMN_DEFAULT  AS 默认值
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employee'
ORDER BY ORDINAL_POSITION;

-- 方法二：系统视图（更全，含注释 description）
SELECT
    c.name           AS 列名,
    t.name           AS 数据类型,
    c.max_length     AS 长度,
    c.is_nullable    AS 允许空,
    dc.definition    AS 默认值,
    ep.value         AS 列说明
FROM sys.columns c
JOIN sys.types t        ON c.user_type_id = t.user_type_id
LEFT JOIN sys.default_constraints dc
       ON dc.object_id = c.default_object_id
LEFT JOIN sys.extended_properties ep
       ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
WHERE c.object_id = OBJECT_ID('dbo.Employee');

-- 方法三：命令方式
EXEC sp_help 'dbo.Employee';

-- 方法四：只看列名清单
EXEC sp_columns @table_name = 'Employee';
```

### 查看主键 / 外键 / 索引

```sql
-- 主键
SELECT
    col.name AS 列名,
    idx.name AS 约束名
FROM sys.indexes idx
JOIN sys.index_columns ic ON idx.object_id = ic.object_id AND idx.index_id = ic.index_id
JOIN sys.columns col      ON ic.object_id = col.object_id AND ic.column_id = col.column_id
WHERE idx.is_primary_key = 1
  AND idx.object_id = OBJECT_ID('dbo.Employee');

-- 外键（含引用关系）
SELECT
    fk.name              AS 外键名,
    OBJECT_NAME(fk.parent_object_id)   AS 子表,
    pc.name              AS 子表列,
    OBJECT_NAME(fk.referenced_object_id) AS 父表,
    rc.name              AS 父表列
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.columns pc ON fkc.parent_object_id = pc.object_id AND fkc.parent_column_id = pc.column_id
JOIN sys.columns rc ON fkc.referenced_object_id = rc.object_id AND fkc.referenced_column_id = rc.column_id
WHERE fk.parent_object_id = OBJECT_ID('dbo.Employee');

-- 索引
EXEC sp_helpindex 'dbo.Employee';
```

---

## 四、增删改查 (CRUD)

### INSERT

```sql
-- 单条（显式列，推荐）
INSERT INTO dbo.Employee (Name, Age, Salary, DeptID)
VALUES (N'张三', 28, 8000.00, 1);

-- 多条
INSERT INTO dbo.Employee (Name, Age, Salary)
VALUES (N'李四', 30, 9000),
       (N'王五', 25, 7000);

-- 从另一张表复制
INSERT INTO dbo.Employee_Bak (Name, Age, Salary)
SELECT Name, Age, Salary FROM dbo.Employee WHERE Age > 25;

-- 表不存在时直接复制结构和数据
SELECT * INTO dbo.Employee_Bak FROM dbo.Employee;
```

### SELECT

```sql
SELECT TOP (100) ID, Name, Age, Salary
FROM dbo.Employee
WHERE Age >= 25 AND DeptID = 1
ORDER BY Salary DESC;

-- 分页（2012+）
SELECT ID, Name, Salary
FROM dbo.Employee
ORDER BY ID
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;   -- 跳过 20 行取 10 行 = 第 3 页

-- 去重 / 条件分支
SELECT DISTINCT DeptID,
       CASE WHEN Salary >= 10000 THEN N'高'
            WHEN Salary >= 5000  THEN N'中'
            ELSE N'低' END AS 薪资等级
FROM dbo.Employee;
```

### DELETE

```sql
-- 删除满足条件的数据
DELETE FROM dbo.Employee WHERE ID = 100;

-- 删除全表（可加 WHERE，可回滚，不重置自增）
DELETE FROM dbo.Employee;

-- 基于另一张表删除
DELETE e
FROM dbo.Employee e
INNER JOIN dbo.Dimissed d ON e.ID = d.EmpID;

-- 清空（快，重置 IDENTITY）
TRUNCATE TABLE dbo.Employee;
```

---

## 五、更新某值

### 基本更新

```sql
-- 更新某个值
UPDATE dbo.Employee
SET Salary = 12000
WHERE ID = 5;

-- 同时更新多列
UPDATE dbo.Employee
SET Salary = Salary * 1.1,      -- 涨薪 10%
    Name  = N'张三丰'
WHERE ID = 5;

-- 用变量 / 表达式更新
DECLARE @NewSalary DECIMAL(12, 2) = 15000;
UPDATE dbo.Employee SET Salary = @NewSalary WHERE ID = 5;

-- NULL 的处理（更新后立刻查）
UPDATE dbo.Employee SET Email = NULL WHERE ID = 5;
SELECT ISNULL(Email, N'未填写') FROM dbo.Employee WHERE ID = 5;
```

### 关联更新（UPDATE ... JOIN）

```sql
-- 按部门表里的系数批量调薪
UPDATE e
SET e.Salary = e.Salary * (1 + d.RaiseRate / 100.0)
FROM dbo.Employee e
INNER JOIN dbo.Department d ON e.DeptID = d.ID
WHERE d.Name = N'研发部';

-- 相关子查询写法
UPDATE dbo.Employee
SET Salary = (SELECT AVG(Salary) FROM dbo.Employee e2 WHERE e2.DeptID = Employee.DeptID)
WHERE DeptID = 1;
```

### 更新前先验证（好习惯）

```sql
BEGIN TRANSACTION;

UPDATE dbo.Employee SET Salary = 20000 WHERE DeptID = 3;

-- 确认影响行数和结果
SELECT ID, Name, Salary FROM dbo.Employee WHERE DeptID = 3;

-- 没问题就提交，有问题回滚
-- COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;
```

### MERGE（存在则更新，不存在则插入）

```sql
MERGE INTO dbo.Employee AS target
USING (VALUES (10, N'赵六', 9500)) AS src (ID, Name, Salary)
ON target.ID = src.ID
WHEN MATCHED THEN
    UPDATE SET Name = src.Name, Salary = src.Salary
WHEN NOT MATCHED THEN
    INSERT (ID, Name, Salary) VALUES (src.ID, src.Name, src.Salary);
```

---

## 六、查询技巧

```sql
-- 模糊查询
SELECT * FROM dbo.Employee WHERE Name LIKE N'张%';
SELECT * FROM dbo.Employee WHERE Name LIKE N'[张李王]%';   -- 姓张/李/王
SELECT * FROM dbo.Employee WHERE Email NOT LIKE '%@qq.com';

-- IN / BETWEEN / 时间范围
SELECT * FROM dbo.Employee WHERE DeptID IN (1, 2, 3);
SELECT * FROM dbo.Employee
WHERE CreatedAt BETWEEN '2026-01-01' AND '2026-12-31 23:59:59';

-- 分组聚合
SELECT DeptID,
       COUNT(*)     AS 人数,
       AVG(Salary)  AS 平均薪资,
       MAX(Salary)  AS 最高,
       MIN(Salary)  AS 最低,
       SUM(Salary)  AS 总额
FROM dbo.Employee
GROUP BY DeptID
HAVING COUNT(*) > 5
ORDER BY 人数 DESC;

-- 连接查询
SELECT e.Name, d.Name AS 部门
FROM dbo.Employee e
LEFT JOIN dbo.Department d ON e.DeptID = d.ID;

-- 取每组前 N（部门薪资 Top 3）
SELECT * FROM (
    SELECT Name, DeptID, Salary,
           ROW_NUMBER() OVER (PARTITION BY DeptID ORDER BY Salary DESC) AS rn
    FROM dbo.Employee
) t WHERE rn <= 3;

-- 日期函数
SELECT
    GETDATE()          AS 当前时间,
    YEAR(GETDATE())    AS 年,
    MONTH(GETDATE())   AS 月,
    DAY(GETDATE())     AS 日,
    DATEADD(DAY, -7, GETDATE())  AS 七天前,
    DATEDIFF(DAY, '2026-01-01', GETDATE()) AS 距元旦天数,
    FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') AS 格式化;
```

---

## 七、索引与约束

```sql
-- 创建索引
CREATE NONCLUSTERED INDEX IX_Employee_DeptID
ON dbo.Employee (DeptID)
INCLUDE (Name, Salary);          -- 覆盖索引，免回表

-- 唯一索引
CREATE UNIQUE INDEX IX_Employee_Email ON dbo.Employee (Email);

-- 查看 / 删除索引
EXEC sp_helpindex 'dbo.Employee';
DROP INDEX IX_Employee_DeptID ON dbo.Employee;

-- 查看索引碎片，决定是否重建
SELECT index_id, index_type_desc, avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.Employee'), NULL, NULL, 'LIMITED');

-- 重建 / 重组索引
ALTER INDEX ALL ON dbo.Employee REBUILD;
ALTER INDEX ALL ON dbo.Employee REORGANIZE;

-- 添加约束
ALTER TABLE dbo.Employee ADD CONSTRAINT UQ_Email UNIQUE (Email);
ALTER TABLE dbo.Employee ADD CONSTRAINT CK_Age CHECK (Age >= 16);
ALTER TABLE dbo.Employee ADD CONSTRAINT DF_Salary DEFAULT 0 FOR Salary;
```

---

## 八、常用系统查询

```sql
-- 查看当前连接 / 正在执行的语句
SELECT session_id, login_time, host_name, program_name, status
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;

-- 查看阻塞链
SELECT
    blocking.session_id AS 阻塞者,
    waiting.session_id  AS 被阻塞者,
    waiting.wait_type,
    dest.text           AS 等待的语句
FROM sys.dm_exec_requests waiting
CROSS APPLY sys.dm_exec_sql_text(waiting.sql_handle) dest
JOIN sys.dm_exec_sessions blocking
     ON blocking.session_id = waiting.blocking_session_id;

-- 杀掉某个会话
KILL 57;

-- 各库大小
SELECT
    d.name AS 数据库,
    CAST(SUM(mf.size) * 8 / 1024.0 AS DECIMAL(10, 2)) AS 大小MB
FROM sys.databases d
JOIN sys.master_files mf ON d.database_id = mf.database_id
GROUP BY d.name
ORDER BY 大小MB DESC;

-- 表行数快速统计（近似值）
SELECT OBJECT_NAME(object_id) AS 表名, SUM(rows) AS 行数
FROM sys.partitions
WHERE index_id IN (0, 1) AND object_id = OBJECT_ID('dbo.Employee')
GROUP BY object_id;

-- 查看执行计划（图形化请用 SSMS 快捷键 Ctrl+M）
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- 执行查询...
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

---

## 九、备份与还原

```sql
-- 完整备份
BACKUP DATABASE TestDB
TO DISK = 'D:\Backup\TestDB_20260815.bak'
WITH COMPRESSION, INIT, STATS = 10;

-- 差异备份
BACKUP DATABASE TestDB
TO DISK = 'D:\Backup\TestDB_diff.bak'
WITH DIFFERENTIAL, STATS = 10;

-- 日志备份
BACKUP LOG TestDB
TO DISK = 'D:\Backup\TestDB.trn'
WITH STATS = 10;

-- 还原
RESTORE DATABASE TestDB
FROM DISK = 'D:\Backup\TestDB_20260815.bak'
WITH MOVE 'TestDB_data' TO 'D:\Data\TestDB.mdf',
     MOVE 'TestDB_log'  TO 'D:\Data\TestDB.ldf',
     RECOVERY, REPLACE, STATS = 10;

-- 查看备份文件内容
RESTORE FILELISTONLY FROM DISK = 'D:\Backup\TestDB_20260815.bak';
```

---

## 十、注意事项

| 事项 | 说明 |
| --- | --- |
| UPDATE / DELETE 必带 WHERE | 先用 SELECT 验证范围，必要时包在事务里 |
| TRUNCATE vs DELETE | TRUNCATE 快、重置自增、不能条件删除、外表有外键引用时不可用 |
| 事务日志膨胀 | 大批量删除建议分批：`DELETE TOP (5000) ... WHERE ...` 循环执行 |
| N 前缀 | 中文字符串请用 `N'中文'`，避免 NVARCHAR 存成乱码 |
| 日期格式 | 推荐用 `'yyyyMMdd'` 或 `'yyyy-MM-ddTHH:mm:ss'`，避免区域设置歧义 |
| 修改列类型 | 有数据时收窄类型或改类型可能失败，先备份数据 |
| 生产环境 DDL | 加列、建索引尽量用在线操作（`WITH (ONLINE = ON)`，企业版） |
