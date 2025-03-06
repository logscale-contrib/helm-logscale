{{- define "humio-instance.nodePools" -}}
{{- range .Values.logscale.nodePools }}
- name: {{ .name }}
  spec:
    image: "{{ $.Values.logscale.image.registry }}/{{ $.Values.logscale.image.repository }}:{{ $.Values.logscale.image.tag }}"
    {{- with $.Values.logscale.image.pullPolicy }}
    imagePullPolicy: {{ . }}
    {{- end }}
    {{- with $.Values.imagePullSecrets }}
    imagePullSecrets:
    {{- toYaml . | nindent 6 }}
    {{- end }}
    nodeCount: {{ .replicas }}
    humioServiceAccountName: {{ include "humio-instance.logscale.serviceAccountName" $ }}
    initServiceAccountName: {{ include "humio-instance.logscale.serviceAccountName" $ }}
    podSecurityContext:
    {{- toYaml $.Values.logscale.commonPod.podSecurityContext | nindent 6 }}
    containerSecurityContext:
    {{- toYaml $.Values.logscale.commonPod.containerSecurityContext | nindent 6 }}
    {{- if or $.Values.logscale.commonPod.podAnnotations .podAnnotations }}  
    podAnnotations:
    {{- with $.Values.logscale.commonPod.podAnnotations }}
        {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .podAnnotations }}
        {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- end }}
    {{- if or $.Values.logscale.commonPod.podLabels .podLabels }}  
    podLabels:
    {{- with $.Values.logscale.commonPod.podLabels }}
        {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .podLabels }}
        {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- end }}

    {{- with .dataVolumePersistentVolumeClaimPolicy }}
    dataVolumePersistentVolumeClaimPolicy: 
      reclaimType: {{ . }}
    {{- end }}
    {{- with .dataVolumePersistentVolumeClaimSpecTemplate }}
    dataVolumePersistentVolumeClaimSpecTemplate:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .environmentVariables }}
    environmentVariables:
    {{- toYaml . | nindent 6 }}
    {{- end }}    
    extraHumioVolumeMounts:
      - name: java-logs
        mountPath: /data/java-logs
      - name: logs
        mountPath: /data/logs
    {{- if $.Values.logscale.trustManagerConfigMap }}
      - name: truststore
        mountPath: /mnt/truststore
    {{- end }}            
      - name: "{{ include "humio-instance.fullname" $ }}-loggingconfig"
        mountPath: /var/lib/humio/config/logging
        readOnly: true     
  {{- include "humio-instance.extraHumioVolumeMountsKafka" $ | nindent 6 }}      
  {{- with $.Values.logscale.extraHumioVolumeMounts }}
  {{- toYaml . | nindent 6 }}
  {{- end }}            
    extraVolumes:
      - name: java-logs
        emptyDir: {}
      - name: logs
        emptyDir: {}
      - name: "{{ include "humio-instance.fullname" $ }}-loggingconfig"
        configMap:
          name: "{{ include "humio-instance.fullname" $ }}-loggingconfig"
      {{- if $.Values.logscale.trustManagerConfigMap }}
      - name: truststore
        configMap:
          # Provide the name of the ConfigMap containing the files you want
          # to add to the container
          name: {{ $.Values.logscale.trustManagerConfigMap }}
      {{- end }}        
      {{- include "humio-instance.extraVolumesKafka" $ | nindent 6 }}
      {{- with $.Values.logscale.extraVolumes }}
      {{- toYaml . | nindent 6 }}
      {{- end }}              
    {{- with .priorityClassName }}
    priorityClassName: {{ . }}
    {{- end }}
    updateStrategy:
      enableZoneAwareness: {{ .updateStrategy.enableZoneAwareness | default true }}
      maxUnavailable: {{ .updateStrategy.maxUnavailable | default 1 }}
      minReadySeconds: {{ .updateStrategy.minReadySeconds | default 45 }}
      type: {{ .updateStrategy.type | default "ReplaceAllOnUpdate" }}
    {{- with .affinity }}
    nodePoolFeatures: 
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .nodeSelector }}
    nodeSelector:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .affinity }}
    affinity:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .tolerations }}
    tolerations:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .topologySpreadConstraints }}
    topologySpreadConstraints:
        {{- toYaml . | nindent 6 }}
    {{- end }}

    humioServiceType: {{ .service.type | default "ClusterIP" }}
    {{- with .service.annotations }}
    humioServiceAnnotations:
    {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .service.labels }}
    humioServiceLabels:
    {{- toYaml . | nindent 6 }}
    {{- end }}    
{{- end }}    
{{- end -}}