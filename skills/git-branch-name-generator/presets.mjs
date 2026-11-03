/**
 * 内置命名规范（Naming Presets）
 *
 * 维护方式：
 * - 每个 preset 只声明「由哪几个部分组成、每部分是什么性质、最终怎么拼接」。
 * - 字段的合法值用枚举（options.values）描述：key 是分支名中允许出现的值，
 *   注释/说明是该值的性质。近义词归并（如「功能/需求」→ feature）由 LLM
 *   按枚举说明完成，脚本只负责校验 LLM 的归类结果是否落在枚举范围内。
 * - 新增 preset：复制最接近的一个，改 fields / template 即可。
 */

/**
 * 类型枚举：GitFlow 风格（default / gitflow 共用）
 * key 即分支名中合法的类型值；描述文字说明该类型的性质，供 LLM 归类。
 */
const GITFLOW_TYPES = {
  feature: '新功能、需求开发、优化与增强',
  bugfix: '常规缺陷修复',
  hotfix: '生产环境紧急修复',
  release: '发布分支',
  chore: '构建、工具、辅助性变更',
  docs: '文档变更',
  refactor: '不改变外部行为的重构',
  test: '测试相关',
  ci: '持续集成配置',
  style: '代码风格、格式调整',
  perf: '性能优化',
  build: '构建系统或外部依赖',
};

/**
 * 类型枚举：Conventional Commits 风格
 * 与 GitFlow 的差异：功能类统称 feat；所有修复（含紧急修复）统称 fix。
 */
const CONVENTIONAL_TYPES = {
  feat: '新功能、需求开发、优化与增强',
  fix: '任何缺陷修复（含生产紧急修复）',
  release: '发布分支',
  chore: '构建、工具、辅助性变更',
  docs: '文档变更',
  refactor: '不改变外部行为的重构',
  test: '测试相关',
  ci: '持续集成配置',
  style: '代码风格、格式调整',
  perf: '性能优化',
  build: '构建系统或外部依赖',
};

/**
 * 类型字段：用户描述需求类型，LLM 按枚举范围归类，脚本校验归类结果。
 * normalize: slug 保证最终值为小写。
 *
 * @param {Record<string, string>} values - 该规范允许的类型枚举
 */
const typeField = (values) => ({
  source: 'input',
  required: true,
  processor: { type: 'llm', operation: 'enum-select', options: { values } },
  normalize: 'slug',
});

/* ------------------------------------------------------------------ */
/* 可复用字段常量：preset 通过引用这些常量组合而成，新增 preset 时按需  */
/* 复用或参照新增字段，不要在 preset 内重复写字段定义。                 */
/* ------------------------------------------------------------------ */

/** 类型字段（GitFlow 枚举范围）：default / gitflow 共用 */
const gitflowTypeField = typeField(GITFLOW_TYPES);

/** 类型字段（Conventional 枚举范围） */
const conventionalTypeField = typeField(CONVENTIONAL_TYPES);

/** 日期字段：取当前日期，格式 YYYYMMDD */
const dateField = {
  source: 'datetime',
  required: true,
  processor: { type: 'transform', format: '%Y%m%d' },
};

/** 需求/工单编号字段：原样传递，保留大小写 */
const idField = {
  source: 'input',
  required: true,
  processor: { type: 'passthrough' },
  normalize: 'token',
};

/** EDY 规范的仓库标识字段：固定前缀 slh */
const edyRepoField = {
  source: 'static',
  required: true,
  processor: { type: 'passthrough', value: 'slh' },
  normalize: 'none',
};

/**
 * 英文描述字段：LLM 将需求提炼为简洁的英文 kebab-case slug。
 * 语义要求见 SKILL.md 第 7 节；max_words 为单词数上限。
 */
const descriptionField = {
  source: 'input',
  required: true,
  processor: {
    type: 'llm',
    operation: 'semantic-slug',
    options: { language: 'en', max_words: 10 },
  },
  normalize: 'slug',
};

/** 默认启用的 preset 名称（只负责指向，preset 本身使用语义化名称） */
export const DEFAULT_PRESET = 'gitflow';

export const presets = {
  // 标准规范：类型/日期-需求编号-英文描述
  // 例：feature/20261102-123-add-user-login
  standard: {
    description: '标准命名规范：类型/日期-需求编号-英文描述',
    max_length: 64,
    fields: {
      type: gitflowTypeField,
      date: dateField,
      id: idField,
      description: descriptionField,
    },
    template: '{type}/{date}-{id}-{description}',
  },

  // Conventional Commits 风格：type/英文描述
  // 例：feat/add-user-login
  conventional: {
    description: 'Conventional Commits 风格：type/英文描述',
    max_length: 64,
    fields: {
      type: conventionalTypeField,
      description: descriptionField,
    },
    template: '{type}/{description}',
  },

  // GitFlow 风格：type/英文描述
  // 例：feature/add-user-login、bugfix/...、hotfix/...
  gitflow: {
    description: 'GitFlow 风格：feature/英文描述',
    max_length: 64,
    fields: {
      type: gitflowTypeField,
      description: descriptionField,
    },
    template: '{type}/{description}',
  },

  // 简洁规范：仅英文描述
  // 例：add-user-login
  simple: {
    description: '简洁命名规范：仅英文描述',
    max_length: 64,
    fields: {
      description: descriptionField,
    },
    template: '{description}',
  },
};
