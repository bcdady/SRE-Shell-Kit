#!/bin/bash

# Usage example:
# ./grant-user.sh ./user-foo.prop ./db-sap-dev.conf

# Step 1
# set new user info

if [ -z "$1" ] || [ ! -f "$1" ]; then
   echo "Error: user source (.prop) file not specified"

    echo ""
    echo "Usage example:"
    echo "$0 ./user-foo.prop ./db-giving-prod.conf"
    echo ""

   exit 17
fi

if [ -z "$2" ] || [ ! -f "$2" ]; then
   echo "Error: DB config file not specified or not found"

    echo ""
    echo "Usage example:"
    echo "$0 ./user-foo.prop ./db-giving-prod.conf"
    echo ""
   exit 26
fi

# Add handling of 3rd and/or 4th parameter to optionally specify RW/CRUD privileges or schemas.
# Default schema remains all and default GRANT is RO/SELECT
if [ -n "$3" ]; then
    case "${3}" in
    "CRUD" )
        PRIV="RW"
    ;;
    "RW" )
        PRIV="RW"
    ;;
    * )
        SCHEMA="$3"
    ;;
    esac
fi

case "${PRIV:-RO}" in
"RW" )
  PRIVILEGES="USAGE, SELECT, INSERT, UPDATE, DELETE"
;;
* )
  PRIVILEGES="USAGE, SELECT"
;;
esac

echo ""

# Get MySQL user info from file contents of 1st argument
echo "loading mysql user properties from $1"
source "$1"

if [ -z "$user_name" ]; then
    echo "user_name is empty"
    exit 38
fi

if [ -z "$user_pass" ]; then
    echo "user_pass is empty"
    exit 43
fi
if [ -z "$user_host" ]; then
    echo "$1 user_host empty"
    exit 47
fi

# Get MySQL server info from file contents of 2nd argument
echo "loading mysql server properties from $2"
TARGET="$2"

grep -v '^#' "$TARGET" |
grep .|
while read -r host port username password; do
    OPTFILE="options/.${host}.cnf"
    cat >"$OPTFILE" <<EOF
[client]
host="${host}"
port="${port:-3306}"
user="${username:-admin}"
password="${password}"
EOF

    printf "Preparing to grant mysql privileges to '%s'@'%s', on %s.\n\n" "$user_name" "$user_host" "$host"

    #  echo "${host}"
    USER_FILE="./users/user.${host}.dat"
    DBS_FILE="./schemas/dbs.${host}.dat"
    USER_GRANT_FILE="./grants/grants.${user_name}.${host}.dat"
    printf " users:\n"
    mysql --defaults-file="$OPTFILE" -BNe "select user,host from mysql.user;" | tee "$USER_FILE" | perl -pe 's/^/\t/g'
    printf " database:\n"
    mysql --defaults-file="$OPTFILE" -BNe "show databases;" | tee "$DBS_FILE" | perl -pe 's/^/\t/g'
    printf ' grants for %s@%s:\n' "'${user_name}'" "'${user_host}'"
    mysql --defaults-file="$OPTFILE" -BNe "show grants for '${user_name}'@'${user_host}';" | tee "$USER_GRANT_FILE" | perl -pe 's/^/\t/g'

    if [ $(grep -c "${user_name}" "$USER_FILE" ) -eq 0 ]; then
        query=$(printf "CREATE USER '%s'@'%s' IDENTIFIED BY '%s';" "${user_name}" "${user_host}" "${user_pass}")
        #echo "$query"
        echo "CREATE USER '%s'@'%s'" "${user_name}" "${user_host}"
        mysql --defaults-file="$OPTFILE" -BNe "$query"
    else
        echo "user exists for ${host}"
        query=$(printf "ALTER USER '%s'@'%s' IDENTIFIED BY '%s';\nFLUSH PRIVILEGES;" "${user_name}" "${user_host}" "${user_pass}")
        echo "ALTER USER '%s'@'%s'" "${user_name}" "${user_host}"
        mysql --defaults-file="$OPTFILE" -BNe "$query"
    fi

    if [ $(grep -c "select on" "$USER_GRANT_FILE" ) -eq 0 ]; then
        query=$(printf "GRANT %s ON *.* to %s@%s;\nFLUSH PRIVILEGES;" "$PRIVILEGES" "'${user_name}'" "'${user_host}'")
        echo "Granting specified privileges:\n$query"
        mysql --defaults-file="$OPTFILE" -BNe "$query"
    else
        echo "Specified privileges are already granted."
    fi

done
