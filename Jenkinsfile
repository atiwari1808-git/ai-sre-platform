pipeline {
  agent any

  environment {
    PROJECT_ID = 'quantum-conduit-506305-t8'
    REGION     = 'us-central1-a'
    REPO       = "us-central1-docker.pkg.dev/${PROJECT_ID}/ai-sre-images"
    CLUSTER    = 'ai-sre-cluster'
  }

<<<<<<< HEAD
  stages {                                    // <-- ADDED: opens the stages block

=======
  stages {
>>>>>>> 1d61d82ba43d5174c7ddd632715fba186eee0c7a
    stage('Authenticate to GCP') {
      steps {
        sh '''
          gcloud config set project $PROJECT_ID
          gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
          gcloud container clusters get-credentials $CLUSTER --region $REGION
        '''
      }
    }

    stage('Build & Push Images') {
      steps {
        sh '''
          docker build -t $REPO/backend:${BUILD_NUMBER} ./backend
          docker push $REPO/backend:${BUILD_NUMBER}

          docker build -t $REPO/frontend:${BUILD_NUMBER} ./frontend
          docker push $REPO/frontend:${BUILD_NUMBER}
        '''
      }
    }

    stage('Deploy to GKE') {
      steps {
        sh '''
          kubectl set image deployment/backend backend=$REPO/backend:${BUILD_NUMBER}
          kubectl set image deployment/frontend frontend=$REPO/frontend:${BUILD_NUMBER}
          kubectl rollout status deployment/backend
          kubectl rollout status deployment/frontend
        '''
      }
    }

  }                                           // <-- ADDED: closes the stages block

  post {
    success {
      echo "✅ Deployed build ${BUILD_NUMBER} successfully!"
    }
    failure {
      echo "❌ Build ${BUILD_NUMBER} failed."
    }
  }
}
