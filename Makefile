install:
		pip install --upgrade pip &&\
		pip install -r requirements.txt

format:
		black *.py

train:
		python train.py

eval:git add .github/workflows/your-workflow.yml
		echo "## Model Metrics" > report.md
		cat ./Results/metrics.txt >> report.md

		echo '\n## Confusion Matrix Plot' >> report.md
		echo '![Confusion Matrix](./Results/model_results.png)' >> report.md

		cml comment create report.md

update-branch:
		git config --global user.name "${{ secrets.USER_NAME }}"
		git config --global user.email "${{ secrets.USER_EMAIL }}"
		git commit -am "Update with new results"
		git push --force origin HEAD:update

hf-login:
		pip install -U "huggingface_hub[cli]"
		git pull origin update
		git switch update
		huggingface-cli login --token $(HF) --add-to-git-credential

push-hub:
		huggingface-cli upload ViniSpark/Drug-Classification ./App --repo-type=space --commit-message="Sync App files"
		huggingface-cli upload ViniSpark/Drug-Classification ./Model /Model --repo-type=space --commit-message="Sync Model"
		huggingface-cli upload ViniSpark/Drug-Classification ./Results /Metrics --repo-type=space --commit-message="Sync Model"

deploy: 
		$(MAKE) hf-login HF=$(HF)
		$(MAKE) push-hub