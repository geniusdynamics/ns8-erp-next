#!/bin/bash

#
# Copyright (C) 2022 Nethesis S.r.l.
# SPDX-License-Identifier: GPL-3.0-or-later
#
rm -vf backup_paths.env
SITE="frontend"
BACKUP_FILE="backup_paths.env"
BASE_DIR="/home/frappe/frappe-bench/sites/"

backup_and_save_paths() {
	local site=$1
	local output

	echo "Running backup for site: $site"

	output=$(podman exec backend bench --site "$site" backup --with-files 2>&1)
	echo "Raw backup output: $output"

	if [[ $? -ne 0 ]]; then
		echo "Error during backup: $output"
		exit 1
	fi

	echo "Backup output received."

	# Extracting paths from output
	local config_path=$(echo "$output" | grep -oP "Config\s*:\s*\K\S+")
	local db_path=$(echo "$output" | grep -oP "Database:\s*\K\S+")
	local public_archive=$(echo "$output" | grep -oP "Public\s*:\s*\K\S+")
	local private_archive=$(echo "$output" | grep -oP "Private\s*:\s*\K\S+")

	# Validate that paths were extracted correctly
	if [[ -z "$config_path" || -z "$db_path" || -z "$public_archive" || -z "$private_archive" ]]; then
		echo "Error extracting backup paths."
		exit 1
	fi

	# Save the paths to the backup file
	{
		echo "CONFIG_PATH=${BASE_DIR}${config_path#./}"
		echo "DB_PATH=${BASE_DIR}${db_path#./}"
		echo "PUBLIC_ARCHIVE=${BASE_DIR}${public_archive#./}"
		echo "PRIVATE_ARCHIVE=${BASE_DIR}${private_archive#./}"
	} >"$BACKUP_FILE"

	echo "Backup paths saved to $BACKUP_FILE"
}

backup_and_save_paths "$SITE"
