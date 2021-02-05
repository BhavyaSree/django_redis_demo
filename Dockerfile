# Use smallest image to reduce surface area of attack
FROM python:3-alpine 

LABEL version="1.0"

LABEL description="Django Demo Application"

# Run as non root user
RUN adduser -D -u 1000 non-root
USER non-root:non-root

COPY --chown=non-root:non-root . /home/non-root

WORKDIR /home/non-root

RUN pip install -r requirements.txt

EXPOSE 8000
ENTRYPOINT [ "python", "manage.py", "runserver", "--verbosity", "2" ]