# config 包开发规则

> 所属模式：标准分层
> 所属层：配置层
> 包路径：`internal/config`

---

## 1. 创建规则

- 项目启动时加载一次，全局使用
- 支持多环境（dev/staging/prod）

## 2. 文件命名规则

`config.go`，复杂时可拆分为 `database.go`, `server.go` 等。

## 3. 代码质量规则

### 【强制】
- 使用 struct 映射配置文件（不用 map[string]any）
- 敏感配置（密码、密钥）从环境变量读取，不硬编码
- 配置加载失败直接Fatal退出

### 【推荐】
- 使用 `viper` 或 `koanf` 库
- 提供默认值
- 启动时校验必填项

## 4. 代码模板

```go
package config

import (
    "fmt"
    "os"

    "github.com/spf13/viper"
)

type Config struct {
    Server   ServerConfig   `mapstructure:"server"`
    Database DatabaseConfig `mapstructure:"database"`
    Redis    RedisConfig    `mapstructure:"redis"`
}

type ServerConfig struct {
    Port int    `mapstructure:"port"`
    Mode string `mapstructure:"mode"` // debug, release
}

type DatabaseConfig struct {
    Host     string `mapstructure:"host"`
    Port     int    `mapstructure:"port"`
    User     string `mapstructure:"user"`
    Password string `mapstructure:"password"` // 从环境变量覆盖
    DBName   string `mapstructure:"dbname"`
}

type RedisConfig struct {
    Addr string `mapstructure:"addr"`
}

func Load() (*Config, error) {
    v := viper.New()
    v.SetConfigName("config")
    v.SetConfigType("yaml")
    v.AddConfigPath("./configs")
    v.AddConfigPath(".")

    // 环境变量覆盖
    v.AutomaticEnv()

    if err := v.ReadInConfig(); err != nil {
        return nil, fmt.Errorf("read config: %w", err)
    }

    var cfg Config
    if err := v.Unmarshal(&cfg); err != nil {
        return nil, fmt.Errorf("unmarshal config: %w", err)
    }

    return &cfg, nil
}

func MustLoad() *Config {
    cfg, err := Load()
    if err != nil {
        fmt.Fprintf(os.Stderr, "failed to load config: %v\n", err)
        os.Exit(1)
    }
    return cfg
}
```
