# Use uma imagem oficial do PHP 8 com Apache
FROM php:8.2-apache

# Instale as dependências necessárias
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
	libicu-dev \
    && docker-php-ext-install zip intl

# Instalar pacores pecl
RUN pecl install redis-5.3.7 \
	&& pecl install xdebug-3.2.1 \
	&& docker-php-ext-enable redis xdebug

# Defina a variável de ambiente APACHE_DOCUMENT_ROOT
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Atualize o arquivo de configuração do Apache para usar o novo diretório raiz
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Atualize o diretório de trabalho do Apache
WORKDIR ${APACHE_DOCUMENT_ROOT}


# Copie o código do CodeIgniter para o diretório de trabalho do Apache
COPY . /var/www/html/

# Defina as permissões corretas
RUN chown -R www-data:www-data /var/www/html/writable

# Exponha a porta 80 para o tráfego da web
EXPOSE 80

# Inicie o Apache no contêiner
CMD ["apache2-foreground"]
