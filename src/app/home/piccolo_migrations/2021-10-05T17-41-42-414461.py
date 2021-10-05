from piccolo.apps.migrations.auto import MigrationManager
from piccolo.columns.column_types import Varchar
from piccolo.columns.indexes import IndexMethod


ID = "2021-10-05T17:41:42:414461"
VERSION = "0.53.0"
DESCRIPTION = ""


async def forwards():
    manager = MigrationManager(
        migration_id=ID, app_name="home", description=DESCRIPTION
    )

    manager.add_table("ProjectLine", tablename="project_line")

    manager.add_column(
        table_class_name="ProjectLine",
        tablename="project_line",
        column_name="name",
        column_class_name="Varchar",
        column_class=Varchar,
        params={
            "length": 255,
            "default": "",
            "null": False,
            "primary_key": False,
            "unique": False,
            "index": False,
            "index_method": IndexMethod.btree,
            "choices": None,
        },
    )

    return manager
