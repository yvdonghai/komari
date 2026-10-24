package database

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/komari-monitor/komari/internal/config"
	"github.com/komari-monitor/komari/internal/metricstore"
)

// GetPublicInfo 返回访客可见的站点公开配置。
// 主题/OAuth 等非探针能力已移除，固定使用默认主题与密码登录。
func GetPublicInfo() (map[string]interface{}, error) {
	cstPtr, err := config.GetManyAs[config.Settings]()
	if err != nil {
		return nil, err
	}
	cst := *cstPtr

	all, allErr := config.GetAll()
	hasKey := func(k string) bool {
		if allErr != nil {
			return false
		}
		_, ok := all[k]
		return ok
	}

	// Apply defaults only when a key is missing.
	if !hasKey("sitename") {
		cst.Sitename = "Komari"
	}
	if !hasKey("description") {
		cst.Description = "Komari Monitor, a simple server monitoring tool."
	}

	// Fallback defaults if we couldn't enumerate keys.
	if allErr != nil {
		if cst.Sitename == "" {
			cst.Sitename = "Komari"
		}
		if cst.Description == "" {
			cst.Description = "Komari Monitor, a simple server monitoring tool."
		}
	}
	retention, err := metricstore.GetRetentionSummary(context.Background())
	if err != nil {
		return nil, err
	}

	return gin.H{
		"sitename":                  cst.Sitename,
		"description":               cst.Description,
		"custom_head":               cst.CustomHead,
		"custom_body":               cst.CustomBody,
		"oauth_enable":              false,
		"oauth_provider":            "",
		"disable_password_login":    false,
		"cors_origin_check_enabled": cst.CorsOriginCheckEnabled,
		"record_enabled":            retention.AllPositive, // 兼容旧版本主题
		"record_preserve_time":      retention.MaxDays * 24,
		"ping_record_preserve_time": retention.MaxDays * 24,
		"private_site":              cst.PrivateSite,
		"visitor_audit_enabled":     cst.VisitorAuditEnabled,
		"theme":                     "default",
		"theme_settings":            gin.H{},
	}, nil
}
