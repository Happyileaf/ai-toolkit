#!/usr/bin/env node
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const SCRIPT_DIR = dirname(fileURLToPath(import.meta.url));
const PRESETS_PATH = join(SCRIPT_DIR, '..', 'presets.json');

/** 默认分支名称最大长度，与 presets.json 中的默认值保持一致 */
const DEFAULT_MAX_LENGTH = 64;

/** Git 分支名称允许的字符：字母、数字、/ . _ - */
const VALID_BRANCH_PATTERN = /^[A-Za-z0-9][A-Za-z0-9/._-]*$/;

/** 分支名称中不允许出现的连续或首尾分隔符 */
const INVALID_SEPARATOR_PATTERN = /\/{2,}|-{2,}|^\/|\/$|^-|-$|\/-|-\//;

/**
 * 读取标准输入内容
 *
 * @returns 解析后的输入字符串
 */
const readStdin = async () => {
  const chunks = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk);
  }
  return Buffer.concat(chunks).toString('utf8');
};

/**
 * 解析命令行输入负载
 * 优先读取命令行第一个参数中的 JSON 字符串，否则从标准输入读取
 *
 * @param argv - 命令行参数
 * @returns 解析后的负载对象
 * @throws 当 JSON 解析失败时抛出异常
 */
const parsePayload = async (argv) => {
  const raw = argv[2] ? argv[2] : await readStdin();
  if (!raw.trim()) {
    return {};
  }
  return JSON.parse(raw);
};

/**
 * 解析当前生效的 Naming Configuration
 * 负载中提供完整 config 时直接使用，否则按 preset 名称从 presets.json 加载
 *
 * @param payload - 输入负载
 * @returns 配置对象与实际使用的 preset 名称
 * @throws 当 preset 不存在或配置结构不合法时抛出异常
 */
const resolveConfig = (payload) => {
  if (payload.config) {
    validateConfigShape(payload.config);
    return { config: payload.config, presetName: 'custom' };
  }
  const presetsFile = JSON.parse(readFileSync(PRESETS_PATH, 'utf8'));
  const presetName = payload.preset || presetsFile.default_preset;
  const config = presetsFile.presets[presetName];
  if (!config) {
    throw new Error(`UNKNOWN_PRESET: 未找到命名规范 ${presetName}`);
  }
  return { config, presetName };
};

/**
 * 校验配置对象的基本结构是否完整
 *
 * @param config - 待校验的配置对象
 * @throws 当缺少 fields 或 template 时抛出异常
 */
const validateConfigShape = (config) => {
  if (!config || typeof config !== 'object' || Array.isArray(config)) {
    throw new Error('INVALID_CONFIG: config 必须是对象');
  }
  if (!config.fields || typeof config.fields !== 'object') {
    throw new Error('INVALID_CONFIG: config.fields 必须是对象');
  }
  if (typeof config.template !== 'string' || !config.template) {
    throw new Error('INVALID_CONFIG: config.template 必须是非空字符串');
  }
};

/**
 * 按 strftime 子集格式化日期
 * 支持 %Y、%m、%d、%H、%M、%S 六个占位符
 *
 * @param date - 日期对象
 * @param format - 日期格式字符串
 * @returns 格式化后的日期字符串
 */
const formatDate = (date, format) => {
  const pad = (value) => String(value).padStart(2, '0');
  const tokenValues = {
    '%Y': String(date.getFullYear()),
    '%m': pad(date.getMonth() + 1),
    '%d': pad(date.getDate()),
    '%H': pad(date.getHours()),
    '%M': pad(date.getMinutes()),
    '%S': pad(date.getSeconds()),
  };
  return format.replace(/%[YmdHMS]/g, (token) => tokenValues[token]);
};

/**
 * 解析负载中指定的当前时间，用于确定性的日期字段处理
 *
 * @param nowInput - ISO 字符串或 YYYY-MM-DD 字符串，缺省时使用系统时间
 * @returns 日期对象
 */
const resolveNow = (nowInput) => {
  if (!nowInput) {
    return new Date();
  }
  const date = new Date(nowInput);
  if (Number.isNaN(date.getTime())) {
    throw new Error(`INVALID_NOW: 无法解析时间值 ${nowInput}`);
  }
  return date;
};

/**
 * 将原始值规范化为 slug 片段
 * 小写、非字母数字字符统一为单个连字符并去除首尾连字符
 *
 * @param value - 原始值
 * @returns 规范化后的 slug
 */
const normalizeSlug = (value) =>
  String(value)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

/**
 * 将原始值规范化为保留大小写的 token 片段
 * 非字母数字字符统一为单个连字符并去除首尾连字符
 *
 * @param value - 原始值
 * @returns 规范化后的 token
 */
const normalizeToken = (value) =>
  String(value)
    .replace(/[^A-Za-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

/**
 * 对字段值执行配置声明的规范化处理
 *
 * @param value - 处理器产出的原始值
 * @param mode - 规范化模式：slug、token 或 none
 * @returns 规范化后的字段值
 */
const applyNormalize = (value, mode) => {
  if (mode === 'slug') {
    return normalizeSlug(value);
  }
  if (mode === 'token') {
    return normalizeToken(value);
  }
  return String(value);
};

/**
 * 按映射表转换字段值
 * 先精确匹配，再忽略大小写匹配
 *
 * @param value - 原始值
 * @param mappings - 映射表
 * @returns 映射结果，未命中时返回 null
 */
const applyMapping = (value, mappings) => {
  const key = String(value);
  if (Object.prototype.hasOwnProperty.call(mappings, key)) {
    return mappings[key];
  }
  const lowerKey = key.toLowerCase();
  const hitKey = Object.keys(mappings).find((item) => item.toLowerCase() === lowerKey);
  return hitKey ? mappings[hitKey] : null;
};

/**
 * 处理单个字段，返回处理后的字段值或错误对象
 *
 * @param name - 字段名称
 * @param definition - 字段配置
 * @param inputs - 用户输入的字段值
 * @param llmValues - LLM 已完成语义处理的字段值
 * @param now - 当前时间对象
 * @returns 包含 value 的成功结果或包含 error 的失败结果
 */
const processField = (name, definition, inputs, llmValues, now) => {
  const fail = (code, message) => ({ error: { code, field: name, message } });
  const source = definition.source || 'input';
  const processor = definition.processor || { type: 'passthrough' };

  let rawValue;
  if (source === 'input') {
    rawValue = inputs[name];
  } else if (source === 'datetime') {
    if (processor.type !== 'transform' || !processor.format) {
      return fail('INVALID_CONFIG', `字段 ${name} 的 datetime 来源需要 transform processor 与 format`);
    }
    rawValue = formatDate(now, processor.format);
  } else if (source === 'static') {
    rawValue = processor.value;
  } else {
    return fail('INVALID_CONFIG', `字段 ${name} 使用了不支持的 source: ${source}`);
  }

  if (processor.type === 'llm') {
    if (llmValues[name] === undefined || llmValues[name] === null) {
      return fail(
        'MISSING_LLM_VALUE',
        `字段 ${name} 需要先执行 LLM 语义处理（operation: ${processor.operation || processor.instruction || 'custom'}），再将结果通过 llm_values.${name} 传入`,
      );
    }
    rawValue = llmValues[name];
  } else if (rawValue === undefined || rawValue === null || rawValue === '') {
    if (definition.required) {
      return fail('MISSING_REQUIRED_FIELD', `缺少必需字段: ${name}`);
    }
    rawValue = '';
  } else if (processor.type === 'mapping') {
    const mapped = applyMapping(rawValue, processor.mappings || {});
    if (mapped === null) {
      return fail('UNMAPPED_VALUE', `字段 ${name} 的值 "${rawValue}" 未在映射表中定义`);
    }
    rawValue = mapped;
  } else if (processor.type === 'transform') {
    if (source !== 'datetime') {
      return fail('INVALID_CONFIG', `字段 ${name} 的 transform processor 仅支持 datetime 来源`);
    }
  } else if (processor.type !== 'passthrough') {
    return fail('INVALID_CONFIG', `字段 ${name} 使用了不支持的 processor: ${processor.type}`);
  }

  const value = rawValue === '' ? '' : applyNormalize(rawValue, definition.normalize || 'slug');
  if (definition.required && !value) {
    return fail('EMPTY_FIELD', `字段 ${name} 规范化后为空`);
  }
  return { value };
};

/**
 * 清洗模板组装后的路径片段
 * 折叠连续连字符、去除片段首尾连字符，并丢弃空片段
 *
 * @param segment - 单个路径片段
 * @returns 清洗后的片段，空片段返回空字符串
 */
const cleanSegment = (segment) =>
  segment
    .replace(/-{2,}/g, '-')
    .replace(/^-+|-+$/g, '');

/**
 * 按模板将字段值组装为完整分支名称
 *
 * @param template - 模板字符串
 * @param fields - 已处理的字段配置
 * @param values - 字段名到处理值的映射
 * @returns 组装结果对象，包含 branch 或 error
 */
const composeBranch = (template, fields, values) => {
  const unknownTokens = [];
  const composed = template.replace(/\{(\w+)\}/g, (match, token) => {
    if (!Object.prototype.hasOwnProperty.call(fields, token)) {
      unknownTokens.push(token);
      return match;
    }
    return values[token] || '';
  });
  if (unknownTokens.length > 0) {
    return { error: { code: 'UNKNOWN_TEMPLATE_FIELD', field: unknownTokens.join(','), message: `模板引用了未定义的字段: ${unknownTokens.join(', ')}` } };
  }
  const segments = composed
    .split('/')
    .map(cleanSegment)
    .filter((segment) => segment !== '');
  return { branch: segments.join('/') };
};

/**
 * 校验最终分支名称与字段级长度约束
 *
 * @param branch - 组装后的分支名称
 * @param values - 字段名到处理值的映射
 * @param fields - 字段配置
 * @param maxLength - 分支名称最大长度
 * @returns 校验错误列表，为空表示全部通过
 */
const validateBranch = (branch, values, fields, maxLength) => {
  const errors = [];

  if (!branch) {
    errors.push({ code: 'EMPTY_BRANCH', field: null, message: '组装后的分支名称为空' });
    return errors;
  }
  if (!VALID_BRANCH_PATTERN.test(branch)) {
    errors.push({ code: 'INVALID_CHARACTER', field: null, message: `分支名称包含非法字符: ${branch}` });
  }
  if (INVALID_SEPARATOR_PATTERN.test(branch)) {
    errors.push({ code: 'INVALID_SEPARATOR', field: null, message: `分支名称存在连续或首尾分隔符: ${branch}` });
  }
  if (branch.includes('..')) {
    errors.push({ code: 'INVALID_REVISION', field: null, message: '分支名称不允许包含连续点号 ..' });
  }
  if (branch.endsWith('.')) {
    errors.push({ code: 'INVALID_REVISION', field: null, message: '分支名称不允许以点号结尾' });
  }
  if (branch.endsWith('.lock')) {
    errors.push({ code: 'LOCKED_REF', field: null, message: '分支名称不允许以 .lock 结尾' });
  }
  if (branch.length > maxLength) {
    errors.push({ code: 'TOO_LONG', field: null, message: `分支名称长度 ${branch.length} 超过上限 ${maxLength}` });
  }

  Object.entries(fields).forEach(([name, definition]) => {
    const maxWords = definition.processor && definition.processor.options && definition.processor.options.max_words;
    if (definition.processor && definition.processor.type === 'llm' && maxWords && values[name]) {
      const wordCount = values[name].split('-').filter(Boolean).length;
      if (wordCount > maxWords) {
        errors.push({
          code: 'WORD_LIMIT_EXCEEDED',
          field: name,
          message: `字段 ${name} 包含 ${wordCount} 个单词，超过上限 ${maxWords}，需要由 LLM 重新提炼，禁止机械截断`,
        });
      }
    }
  });

  return errors;
};

/**
 * 将错误结果输出到标准输出并以非零状态退出
 *
 * @param errors - 错误列表
 */
const outputErrors = (errors) => {
  process.stdout.write(`${JSON.stringify({ ok: false, errors }, null, 2)}\n`);
  process.exit(1);
};

/**
 * 主流程：解析配置、处理字段、组装名称、校验并输出
 *
 * @param argv - 命令行参数
 */
const main = async (argv) => {
  let payload;
  try {
    payload = await parsePayload(argv);
  } catch {
    outputErrors([{ code: 'INVALID_PAYLOAD', field: null, message: '输入负载不是合法 JSON' }]);
    return;
  }

  let resolved;
  try {
    resolved = resolveConfig(payload);
  } catch (error) {
    outputErrors([{ code: 'CONFIG_ERROR', field: null, message: error.message }]);
    return;
  }

  const { config, presetName } = resolved;
  let now;
  try {
    now = resolveNow(payload.now);
  } catch (error) {
    outputErrors([{ code: 'INVALID_NOW', field: null, message: error.message }]);
    return;
  }

  const inputs = payload.inputs || {};
  const llmValues = payload.llm_values || {};
  const values = {};
  const errors = [];

  Object.entries(config.fields).forEach(([name, definition]) => {
    const result = processField(name, definition, inputs, llmValues, now);
    if (result.error) {
      errors.push(result.error);
    } else {
      values[name] = result.value;
    }
  });

  if (errors.length > 0) {
    outputErrors(errors);
    return;
  }

  const composed = composeBranch(config.template, config.fields, values);
  if (composed.error) {
    outputErrors([composed.error]);
    return;
  }

  const validationErrors = validateBranch(composed.branch, values, config.fields, config.max_length || DEFAULT_MAX_LENGTH);
  if (validationErrors.length > 0) {
    outputErrors(validationErrors);
    return;
  }

  process.stdout.write(`${JSON.stringify({ ok: true, preset: presetName, branch: composed.branch, fields: values }, null, 2)}\n`);
};

main(process.argv);
