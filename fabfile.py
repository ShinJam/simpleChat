import json
import os
from pathlib import Path
import base64

from fabric.api import local

ROOT_DIR_PATH = Path(__file__).parent.resolve()


def _get_dotenv_file(stage, project):
	return ROOT_DIR_PATH / project / f".env.{stage}"


def _import_env_json(stage, project) -> dict:
	envs = {}
	filepath = _get_dotenv_file(stage, project)
	with open(filepath, "r") as f:
		content = f.readlines()
		for x in content:
			if "=" not in x or x.startswith("#"):
				continue
			k, v = x.strip().split("=", 1)
			if not v:
				continue
			# convert to base64 string
			v_bytes = v.encode('ascii')
			v_base64 = base64.b64encode(v_bytes)
			v_base64_str = v_base64.decode('ascii')
			envs[k] = v_base64_str
	return dict(envs)


def hello(stage, project):
	for k, v in _import_env_json(stage, project).items():
		print(f"{k}: {v}")


def update_ssm_parameters(
	service: str = "kuve_eks",
	stage: str = "",
	project: str = "",
	region: str = "ap-northeast-2",
	overwrite: int = 1,
):
	new_envs = _import_env_json(stage, project)
	encryption_key = os.environ.get("AWS_KMS_KEY_FOR_SSM_PARAMETER_ENCRYPTION")

	overwrite_flag = ""
	if overwrite:
		overwrite_flag = "--overwrite"

	existing_envs = local(
		f"aws ssm get-parameters-by-path \
				--path '/{service}/{stage}/{project}' \
				--with-decryption \
				--region {region}",
		capture=True,
	)
	existing_envs_json = json.loads(existing_envs)
	existing_keys = [d["Name"].split("/")[-1] for d in existing_envs_json["Parameters"]]
	keys_to_delete = set(existing_keys) - set(new_envs.keys())

	for name, value in new_envs.items():
		cmd = f"aws ssm put-parameter \
			--name /{service}/{stage}/{project}/{name} \
			--value '{value}' \
			--type SecureString \
			--key-id {encryption_key} \
			{overwrite_flag}"
		if overwrite:
			cmd += " > /dev/null"
		local(cmd)

	print(f"삭제할 키 목록입니다 - {keys_to_delete}.")
	if keys_to_delete:
		for key in keys_to_delete:
			local(
				f"aws ssm delete-parameter \
				--name /{service}/{stage}/{project}/{key}"
			)


def delete_ssm_parameters(
	service: str = "kuve",
	stage: str = "",
	project: str = "",
	region: str = "ap-northeast-2",
):
	existing_envs = local(
		f"aws ssm get-parameters-by-path \
				--path '/{service}/{stage}/{project}' \
				--with-decryption \
				--region {region}",
		capture=True,
	)
	existing_envs_json = json.loads(existing_envs)
	existing_names = [d["Name"] for d in existing_envs_json["Parameters"]]

	for i in range(0, 100, 10):
		names = existing_names[i: i + 10]  # noqa
		name_param = " ".join(f'"{k}"' for k in names)
		local(f"aws ssm delete-parameters --names {name_param}")

		if len(names) != 10:
			print("Deletion complete.")
			return
