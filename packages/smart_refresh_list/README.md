这是一个基于 pull_to_refresh 的列表刷新和分页加载库

## 核心功能

### 分层组件设计：

- `SmartRefreshWidget`：基础刷新组件，提供最大的灵活性
- `SmartRefreshList`：专门用于列表展示的刷新组件
- `SmartRefreshGrid`：专门用于网格展示的刷新组件

### 完整的状态管理：

- 内置 `SmartRefreshController` 管理刷新状态和数据
- 支持自动分页加载，无需手动管理页码
- 提供数据去重功能

### 丰富的配置选项：

- 可自定义头部、底部样式和配置
- 支持主题适配和样式配置
- 提供空状态和错误状态组件

### 多种布局支持：

- ListView 列表布局
- GridView 网格布局（支持固定列数、最大交叉轴范围等多种模式）