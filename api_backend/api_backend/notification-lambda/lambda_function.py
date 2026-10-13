import json
import logging
import os
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ses = boto3.client("ses")
SENDER = os.environ["SENDER_EMAIL"]


def handler(event, context):
    failures = []
    logger.info("Registros recibidos: %d", len(event.get("Records", [])))

    for record in event["Records"]:
        try:
            body = json.loads(record["body"])
            # Con raw_message_delivery=false, el mensaje viene dentro de "Message"
            payload = json.loads(body["Message"]) if "Message" in body else body

            to = payload["email"]
            subject = payload["subject"]
            message = payload["message"]

            logger.info("Enviando correo a %s (messageId=%s)", to, record["messageId"])
            resp = ses.send_email(
                Source=SENDER,
                Destination={"ToAddresses": [to]},
                Message={
                    "Subject": {"Data": subject, "Charset": "UTF-8"},
                    "Body": {"Text": {"Data": message, "Charset": "UTF-8"}},
                },
            )
            logger.info("Correo enviado. SES MessageId=%s", resp["MessageId"])
        except Exception:
            logger.exception("Error procesando messageId=%s", record["messageId"])
            failures.append({"itemIdentifier": record["messageId"]})

    # Solo los mensajes fallidos vuelven a la cola (y luego a la DLQ)
    return {"batchItemFailures": failures}