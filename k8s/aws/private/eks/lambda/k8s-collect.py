from typing import Any, Dict

import boto3
from kubernator_common import logger, return_with_logs, run_kubernator  # type: ignore  # pants: no-infer-dep

UPDATE_FUNC_PARAM = "update_func"

client = boto3.client("lambda")


def update_lambda(config: Dict[str, Any]) -> None:
    logger.info(f"Updating function configuration {config}")
    client.update_function_configuration(**config)


def lambda_handler(event: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
    if UPDATE_FUNC_PARAM in event:
        update_params = event.pop(UPDATE_FUNC_PARAM)
        try:
            update_lambda(update_params["config"])
        except Exception as e:
            logger.error(f"Failed to update function configuration: {str(e)}")
            return return_with_logs(400, {"error": f"Failed to update function configuration: {str(e)}"})  # type: ignore

        return return_with_logs(200, {"message": "lambda configuration was updated"})  # type: ignore

    return run_kubernator(event)  # type: ignore
