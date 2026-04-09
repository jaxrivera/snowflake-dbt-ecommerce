# War Room Log: Errors & Solutions

| Error Code / Message | Root Cause | Resolution |
| :--- | :--- | :--- |
| `Incorrect username or password` | Snowflake account URL mismatch or expired credentials. | Verified Account Locator format in `profiles.yml` and utilized GitHub Personal Access Token for Git authentication. |
| `Insufficient privileges` | Role lacked schema creation rights. | Ran `GRANT CREATE TABLE, CREATE VIEW ON SCHEMA...` in Snowflake. |
