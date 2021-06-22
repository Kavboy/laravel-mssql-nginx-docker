#!/bin/bash
if [ -f "./.installed" ]; then
    exit 0
fi

echo "PHP Waiting for MS SQL to be finished creating ⏳"

# wait for MSSQL server to finish install
export STATUS=1
i=0

while [[ $STATUS -ne 0 ]] && [[ $i -lt 30 ]]; do
    sleep 3s
    i=$i+1
	if [ -f "./docker/mssql/data/.sql-created" ]; then
	    STATUS=0
	fi
done

if [ $STATUS -ne 0 ]; then
	echo "PHP Container Error: MSSQL SERVER took more than ninety seconds to start up."
	exit 1
fi

cd laravel || exit

echo =============== PHP MSSQL STARTED                   ==========================

echo =============== PHP Composer Install                ==========================
composer install --optimize-autoloader --no-dev

echo =============== PHP Create Key                      ==========================
php artisan key:generate

echo =============== PHP Clear                           ==========================
php artisan cache:clear
php artisan optimize:clear
php artisan config:clear
php artisan route:clear

echo =============== PHP New Config                      ==========================
php artisan config:cache

echo =============== PHP New View cache                  ==========================
php artisan view:cache

echo =============== PHP Migrate                         ==========================
php artisan migrate --seed

echo =============== PHP New Route cache                 ==========================
php artisan route:cache

echo =============== PHP Optimize                        ==========================
php artisan optimize

echo =============== PHP Finished                        ==========================
touch ./.installed
