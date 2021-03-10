deploy: apply
	cd ~/workspace/stddbc/dist/ && \
		/Users/georgeabuzo/workspace/scripts/aws s3 sync ./ \
		s3://mywebsite.pablosspot.ml

apply: plan
	terraform apply $(TF_WORKSPACE).tfplan
	rm $(TF_WORKSPACE).tfplan

plan: init
	terraform plan -out $(TF_WORKSPACE).tfplan

init:
	terraform init