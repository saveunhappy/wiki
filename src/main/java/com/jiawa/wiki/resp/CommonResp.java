package com.jiawa.wiki.resp;

public class CommonResp<T> {
    /**
     * 业务上的成功或者失败
     */
    private boolean success = true;

    /**
     * 返回信息
     */
    private String message;

    private T content;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getContent() {
        return content;
    }

    public void setContent(T content) {
        this.content = content;
    }
}
