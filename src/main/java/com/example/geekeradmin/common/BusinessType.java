package com.example.geekeradmin.common;

/**
 * 日志业务类型
 */
public enum BusinessType {
    /** 新增 */
    INSERT,
    /** 修改 */
    UPDATE,
    /** 删除 */
    DELETE,
    /** 查询 */
    SELECT,
    /** 导出 */
    EXPORT,
    /** 登录 */
    LOGIN,
    /** 登出 */
    LOGOUT,
    /** 其它 */
    OTHER
}
