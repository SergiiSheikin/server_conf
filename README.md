# Разгортання сервера астериск 13 + freepbx 13 на Centos7
Першим запускаємо скрипт start.sh
    файл .env треба заповнити
що робить скрипт
    інтерфейс налаштовуемо на статику
    відключаємо SELinux
    вимикаємо firewalld
    вимикаємо NetworkManager
    робимо update
    встановлюємо Development Tools
    встановлюємо інші залежності
    запуск mariadb, httpd
    додавання юзера asterisk
    скачування та встановлення 
        dahdi-linux-complete-current.tar.gz
        libpri-1-current.tar.gz
        asterisk-13.38.3.tar.gz
        jansson.tar.gz
        freepbx-13.0-latest.tgz
    заборона входу по SSH root
Другим запускаємо setup_freepbx_service.sh
Третій install_tftp.sh



    
