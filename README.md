# ReadTheDocs (RTD) Docker 

[![](https://images.microbadger.com/badges/image/qqbuby/readthedocs.svg)](https://microbadger.com/images/qqbuby/readthedocs "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/qqbuby/readthedocs.svg)](https://microbadger.com/images/qqbuby/readthedocs "Get your own version badge on microbadger.com")

The basic docker image that responds to the `qqbuby/readthedocs:latest`.

- `EXPOSE 80`
  
- `CMD ["python", "./manage.py", "runserver", "0.0.0.0:8000"]`
  
- ENV:

    `RTD_REPO_DIR＝/var/readthedocs`
    
    `RTD_COMMIT=2a54e3adf487412f58a0a4473c0a52250b15ff18`
