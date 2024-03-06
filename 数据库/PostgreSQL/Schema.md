[toc]

# Schema

## Schema介绍

Schema 是指数据库中用来组织和命名对象的集合的逻辑容器。在 PostgreSQL 中，Schema 用于对数据库对象进行逻辑分组和隔离，类似于文件系统中的文件夹，可以帮助用户更好地组织和管理数据库对象。

在一个数据库中，可以创建多个 Schema，并且每个 Schema 可以包含表、视图、函数、索引等数据库对象。默认情况下，PostgreSQL 数据库会包含一个名为 "public" 的 Schema，如果在创建对象时没有显式指定所属的 Schema，那么对象将被创建在 "public" Schema 中。

通过使用 Schema，可以实现以下几个重要的功能：

1. **命名空间隔离**：不同的 Schema 可以包含相同名称的对象，因此可以避免对象名称的冲突，提高了数据库对象的命名空间隔离性。
2. **权限控制**：可以通过授权不同的 Schema 访问权限，实现对数据库对象的权限控制。
3. **逻辑组织**：可以根据业务逻辑或功能需求将相关的对象组织到不同的 Schema 中，使得数据库结构更加清晰易懂。

要在 PostgreSQL 中创建一个新的 Schema，可以使用如下 SQL 命令：

```
CREATE SCHEMA schema_name;
```

例如，要创建一个名为 "my_schema" 的新 Schema，可以执行以下 SQL 命令：

```
CREATE SCHEMA my_schema;
```

一旦创建了新的 Schema，就可以在其中创建表、视图和其他数据库对象，并通过指定 Schema 名称来引用这些对象。

总之，Schema 在 PostgreSQL 中是一个非常有用的工具，它能够帮助用户更好地组织和管理数据库对象，从而提高数据库的可维护性和可扩展性。

## 默认Schema

在 PostgreSQL 中，`public` schema 是默认的 schema，它是新创建的数据库中所有未显式指定 schema 的对象所属的默认 schema。当您创建一个新的表、视图、函数等数据库对象时，如果没有指定所属的 schema，这些对象将会被创建在 `public` schema 中。

以下是关于 `public` schema 的一些重要信息和特点：

1. **默认 schema**: 如果在创建对象时没有指定所属的 schema，PostgreSQL 将会将这些对象放置在 `public` schema 中。
2. **可见性**: 所有用户对 `public` schema 中的对象都具有访问权限，除非显式地撤销访问权限。
3. **公共访问**: `public` schema 中的对象对所有用户都是可见的，并且大多数用户都可以执行相应的操作（如查询表、调用函数等）。
4. **模板数据库**: 在新建数据库时，默认情况下，该数据库会继承模板数据库中的一些设置，包括 `public` schema 中的对象。因此，如果您希望在每个新创建的数据库中都有一些通用的对象或数据，可以在 `public` schema 中创建这些对象。
5. **系统默认设置**: `public` schema 中包含了一些系统默认的对象，例如常见的 PostgreSQL 数据类型、函数等，这些对象对于数据库的正常运行是必需的。

总的来说，`public` schema 在 PostgreSQL 中扮演着一个默认的角色，用于存储大部分用户创建的数据库对象。通过合理使用 `public` schema，可以使得数据库对象的组织更清晰，同时也方便用户对数据库对象进行管理和访问。

## 其他Schema

1. **`pg_catalog` schema**: `pg_catalog` schema 包含了 PostgreSQL 数据系统中的所有系统表，这些系统表存储了关于数据库对象（如表、索引、数据类型等）的元数据信息。这些表是 PostgreSQL 数据系统的一部分，用于支持数据库的正常运行和管理。
2. **`pg_temp_N` schema**: 当您在会话中创建临时表时，这些临时表会被放置在名为 `pg_temp_N` 的特殊 schema 中，其中 N 是当前会话的标识符。这些临时表只在当前会话中存在，并在会话结束时自动删除。
3. **`pg_toast` schema** : 用于存储大型值（例如大文本或大二进制对象）的分块数据。当表的某列中存储的值超过一定大小限制时，这些大型值将被自动移动到 `pg_toast` schema 中进行存储。
4. **`information_schema` schema**:  用于存储关于数据库对象（如表、列、约束等）元数据信息的系统视图。在 PostgreSQL 中，`information_schema` schema 提供了一组标准的系统视图，这些视图可以用于查询和检索数据库对象的元数据信息，例如表的结构、列的数据类型、约束信息等

