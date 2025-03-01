package main

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/heroiclabs/nakama-common/runtime"
)

type HealthcheckReponse struct {
	Success bool `json: "success"`
}

func RpcHealthcheck(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	logger.Debug("Healthcheck RPC called")

	response := &HealthcheckReponse{Success: true}

	out, err := json.Marshal(response)
	if err != nil {
		logger.Error("Error marshaling response to JSON: %v:", err)
		return "", runtime.NewError("Cannon marshal type", 13)
	}

	return string(out), nil
}
