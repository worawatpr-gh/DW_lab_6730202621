# install dbt-duckdb
pip install dbt-duckdb

# freeze and save to requiremets.txt
pip freeze > requirements.txt
# initialize dbt project
dbt init <dbt-project-name>
# move to <dbt-project-name>
cd <dbt-project-name>
# test or debug
dbt debug
# mone back to the main folder
cd ..