FROM python:3.6
ENV PROJECT_DIR=ethereum-etl

RUN mkdir /$PROJECT_DIR

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Copy code
WORKDIR /$PROJECT_DIR
COPY . .
RUN pip install --upgrade pip && pip install -e /$PROJECT_DIR/[streaming]

CMD ["/ethereum-etl/export.sh"]
