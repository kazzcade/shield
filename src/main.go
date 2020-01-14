package main

import (
	"context"
	"os"

	"encoding/json"

	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

type BuildDetail struct {
	Status string `json:"build-status"`
	Name   string `json:"project-name"`
}

//HandleRequest handle she change for a given codebuild alarm
func HandleRequest(ctx context.Context, event events.CloudWatchEvent) error {
	buildDetail := BuildDetail{}
	if err := json.Unmarshal(event.Detail, &buildDetail); err != nil {
		return fmt.Errorf("Unable to unmarshal event details %w", err)
	}

	bucket := os.Getenv("BUCKET")

	if len(bucket) <= 0 {
		return fmt.Errorf("Unable to update project %s with a status of %s, Please set BUCKET environment variable", buildDetail.Name, buildDetail.Status)
	}

	source := fmt.Sprint("%s/%s.svg", bucket, buildDetail.Status)
	destination := fmt.Sprintf("%s/%s/STATUS.svg", bucket, buildDetail.Name)

	sess, sessErr := session.NewSession()

	if sessErr != nil {
		return fmt.Errorf("Unable to create a session %w", sessErr)
	}

	svc := s3.New(sess)

	// copy the object
	_, copyErr := svc.CopyObject(&s3.CopyObjectInput{Bucket: aws.String(bucket), CopySource: aws.String(source), Key: aws.String(destination)})
	if copyErr != nil {
		return fmt.Errorf("Error copying status from %s to %s %w", source, destination, copyErr)
	}

	// Wait to see if the item got copied
	copyWaitErr := svc.WaitUntilObjectExists(&s3.HeadObjectInput{Bucket: aws.String(source), Key: aws.String(destination)})
	if copyWaitErr != nil {
		return fmt.Errorf("Error waiting for item %s to be copied to %s %w", source, destination, copyWaitErr)
	}

	return nil
}

func main() {
	lambda.Start(HandleRequest)
}
